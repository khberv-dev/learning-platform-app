class PaymentTypeEntity {
  final String id;
  final String title;

  /// Absolute URL, already resolved from the path the API returned.
  final String? iconUrl;

  /// The provider's checkout page, e.g. https://payme.uz/checkout.
  final String? checkoutUrl;

  const PaymentTypeEntity({
    required this.id,
    required this.title,
    this.iconUrl,
    this.checkoutUrl,
  });
}
