String toMaxDecimalPlacesOmitTrailingZeroes(double n, int places) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : places);
}
