import 'dart:math' as math;
import 'dart:typed_data';

/// Configuration for DoG + power-law preprocessing.
class PreprocessingConfig {
  const PreprocessingConfig({
    this.doG = true,
    this.doGSigma1 = 1.0,
    this.doGSigma2 = 1.6,
    this.compression = true,
    this.compressionExponent = 0.7,
  });

  final bool doG;
  final double doGSigma1;
  final double doGSigma2;
  final bool compression;
  final double compressionExponent;
}

const defaultPreprocessingConfig = PreprocessingConfig();

/// Normalized 1D Gaussian kernel.
Float32List makeGaussianKernel(double sigma, [int? radius]) {
  final r = radius ?? (sigma * 3).ceil();
  final size = 2 * r + 1;
  final kernel = Float32List(size);
  final twoSigmaSq = 2 * sigma * sigma;
  var sum = 0.0;

  for (var i = 0; i < size; i++) {
    final x = i - r;
    kernel[i] = math.exp(-(x * x) / twoSigmaSq);
    sum += kernel[i];
  }

  for (var i = 0; i < size; i++) {
    kernel[i] /= sum;
  }

  return kernel;
}

/// Separable Gaussian blur with boundary clamping.
Float32List gaussianBlur(
  Float32List data,
  int width,
  int height,
  double sigma,
) {
  if (sigma <= 0) return Float32List.fromList(data);

  final kernel = makeGaussianKernel(sigma);
  final r = (kernel.length - 1) ~/ 2;

  final temp = Float32List(width * height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var sum = 0.0;
      for (var k = -r; k <= r; k++) {
        final sx = (x + k).clamp(0, width - 1);
        sum += data[y * width + sx] * kernel[k + r];
      }
      temp[y * width + x] = sum;
    }
  }

  final result = Float32List(width * height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var sum = 0.0;
      for (var k = -r; k <= r; k++) {
        final sy = (y + k).clamp(0, height - 1);
        sum += temp[sy * width + x] * kernel[k + r];
      }
      result[y * width + x] = sum;
    }
  }

  return result;
}

/// Difference of Gaussians with half-wave rectification (clamp ≥ 0).
Float32List applyDoG(
  Float32List weights,
  int width,
  int height, {
  double sigma1 = 1.0,
  double sigma2 = 1.6,
}) {
  final narrow = gaussianBlur(weights, width, height, sigma1);
  final wide = gaussianBlur(weights, width, height, sigma2);
  final result = Float32List(width * height);

  for (var i = 0; i < result.length; i++) {
    result[i] = math.max(0.0, narrow[i] - wide[i]);
  }

  return result;
}

/// Compressive nonlinearity `w' = w^p` (p < 1 emphasises edges).
Float32List applyPowerCompression(
  Float32List weights, {
  double exponent = 0.7,
}) {
  final result = Float32List(weights.length);
  for (var i = 0; i < weights.length; i++) {
    if (weights[i] > 0) {
      result[i] = math.pow(weights[i], exponent).toDouble();
    }
  }
  return result;
}

/// DoG then power compression. Returns a new array; [weights] is unchanged.
Float32List preprocessWeightMap(
  Float32List weights,
  int width,
  int height, [
  PreprocessingConfig config = defaultPreprocessingConfig,
]) {
  var result = weights;

  if (config.doG) {
    result = applyDoG(
      result,
      width,
      height,
      sigma1: config.doGSigma1,
      sigma2: config.doGSigma2,
    );
  }

  if (config.compression) {
    result = applyPowerCompression(
      result,
      exponent: config.compressionExponent,
    );
  }

  return result;
}
