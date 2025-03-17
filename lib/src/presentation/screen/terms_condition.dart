import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final String termsText = '''
A message to our customers.

We pride ourselves on being a responsible and reputable dry cleaner, for those of you who are familiar with us you will understand that we are incredibly thorough in our processes and standards. However, like in any industry, there are conditions and situations that we cannot always predict regardless of our extensive experience. In line with our policy to always remain transparent with our customers, the below sections outline our terms and conditions as well as informing our customers of specific garments and fabrics that require a better understanding. If you have any questions or would like further information apart from the information written below, we would love for you to reach out to us.

General conditions

Turnaround time of dry cleaning orders is normally 5 days. Express/Urgent orders would be charged 50% extra over the regular tariff. We provide pickup & drop services on customer request, however, minimum order value should be Rs. 300/-. We put in our best efforts to ensure timely pick-up and delivery; however there might be incidents beyond our control or incidences of Force Majeure where we are unable to stick to the timelines. In such cases, customer cannot claim any compensation, refunds or any reduction in charges. We put our best efforts to remove any stains or unwanted marks on the clothes; however we cannot guarantee 100% removal of stains or marks. Customer has to pay service charges even if stains or marks do not remove. You are requested to check your article before handing it over to Fabspin Drycleaners, we would not take any responsibility for valuables/article/cash, etc. inadvertently kept in the articles which is mutilated or unrecoverable after processing.

Service Exclusions

Whilst we take every precaution to protect and safely process your items, due to the unpredictable nature of certain fabrics, dyes and accessories; the following items are only cleaned at an owner’s risk.

Items void of a care label or cleaning instructions

Leather, Suede and Fur Garments
Items containing leather, suede or fur features (elbow patches, leather collars)
Belts, Buckles, Buttons and Hooks (The following can detach or wear during the cleaning process)
Vintage Garments
Weak and Ageing Fabrics
Re-Cleaning of stained garments (This can cause damage due to further solvent usage)
Other Garments previously agreed to be cleaned with an ‘Owners Risk’.
Loss & Damage

In the unlikely event whereby loss or damage has occurred to a garment, the following protocols should be followed.

How to communicate issues?

If you have a question or complaint about the service, please contact us within 48 hours of receiving your garments ensuring the garment has not been worn and in its original packaging. You can reach out to us through our email address: info@fabspin.com

You can also report issues to one of our in-store teams however please note all matters will subsequently be passed onto our head office.

Unfortunately we are unable to process claims 48 hours after collection.

We appreciate that due to an extensive customer base things may go wrong. Your feedback and cooperation is requested in trying to put things right and we aim to do this quickly and efficiently.

Responsibility

In the event whereby damage of loss has been caused due to negligence or ‘foreseeable’ damage, not intercepted by our team; we will of course accept responsibility.

 We are unable to accept responsibility however under the following terms:

In the event an item has been cleaned in direct correspondence with the care label issued by the manufacturer.
Damage caused by items left inside garment pockets eg. pens, tissues, business cards, pins, jewellery etc. We encourage our customers to thoroughly check before dropping in items.
Garments returned after 48 hours of collection, not within original packaging.
Ageing of garment experienced after cleaning a garment for the first time.
Damage caused after re-cleaning a garment.
Associated garments, a trousers linked to a suit jacket.
Items with deliberate crinkles, or pleats which are removed during the cleaning process.
Garments with previous inherent weaknesses which are exposed after cleaning (old and ageing fabrics). This includes colour loss and shrinkage.
In the case we are responsible for damage, our liability will be limited to the lesser of:

10x the cleaning price paid for the garment.
The depreciated value of the item as determined by International fair claims guide for consumer textiles products as provided by the Drycleaning Institute of Australia.
Upon agreement of any compensation figure, the company reserves the right to the garment and cannot be returned. Instead all items are then donated to local charity.

Based on above terms & conditions, we would potentially compensate you once liability is proved by us, this would be considered once the age, original value and proof of purchase is established. We are unable to replace old with new items and therefore require the age, state and condition of the item(s) prior to any compensation settlement.
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Terms and Conditions', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Text(
          termsText,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
