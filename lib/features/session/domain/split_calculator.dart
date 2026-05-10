import '../data/models/item_model.dart';

class SplitCalculator {
  static Map<String, double> calculate({
    required List<ItemModel> items,
    required double taxPercent,
    required double serviceChargePercent,
  }) {
    Map<String, double> subtotalPerPerson = {};

    // 1. Calculate subtotal share for each person
    for (var item in items) {
      double totalShares = item.assignedShares.values.fold(0, (sum, share) => sum + share);
      
      if (totalShares > 0) {
        item.assignedShares.forEach((personId, shareMultiplier) {
          double personShareAmount = (shareMultiplier / totalShares) * item.price;
          subtotalPerPerson[personId] = (subtotalPerPerson[personId] ?? 0) + personShareAmount;
        });
      }
    }

    double totalSubtotal = subtotalPerPerson.values.fold(0, (sum, sub) => sum + sub);
    
    // 2. Calculate tax and service charge absolute amounts
    double totalTax = totalSubtotal * (taxPercent / 100);
    double totalServiceCharge = totalSubtotal * (serviceChargePercent / 100);
    double grandTotal = totalSubtotal + totalTax + totalServiceCharge;

    Map<String, double> finalTotalPerPerson = {};
    double distributedTotal = 0;

    // 3. Distribute tax and service charge proportionally
    List<String> personIds = subtotalPerPerson.keys.toList();
    for (int i = 0; i < personIds.length; i++) {
      String personId = personIds[i];
      double subtotal = subtotalPerPerson[personId]!;
      
      // Calculate proportion
      double proportion = totalSubtotal > 0 ? subtotal / totalSubtotal : 0;
      
      double personTax = totalTax * proportion;
      double personServiceCharge = totalServiceCharge * proportion;
      double personTotal = subtotal + personTax + personServiceCharge;

      // Round to 2 decimal places
      double roundedTotal = double.parse(personTotal.toStringAsFixed(2));
      
      finalTotalPerPerson[personId] = roundedTotal;
      distributedTotal += roundedTotal;
    }

    // 4. Adjust for rounding differences on the last person
    if (personIds.isNotEmpty) {
      double expectedGrandTotal = double.parse(grandTotal.toStringAsFixed(2));
      double diff = double.parse((expectedGrandTotal - distributedTotal).toStringAsFixed(2));
      
      if (diff != 0) {
        String lastPersonId = personIds.last;
        finalTotalPerPerson[lastPersonId] = double.parse((finalTotalPerPerson[lastPersonId]! + diff).toStringAsFixed(2));
      }
    }

    return finalTotalPerPerson;
  }
}
