import 'package:fabspinrider/model/order.dart';
import 'package:flutter/material.dart';

import '../../screen/widgets/order_card.dart';


class BottomContainer extends StatefulWidget {
  final PickupDrop order;
  final VoidCallback pickUpHandler;
  final VoidCallback deliverHandler;
  const BottomContainer(
      {super.key,
      required this.order,
      required this.pickUpHandler,
      required this.deliverHandler});

  @override
  State<BottomContainer> createState() => _BottomContainerState();
}

class _BottomContainerState extends State<BottomContainer> {
  bool isCommentSeeMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primary,
                backgroundImage: NetworkImage(
                 'https://images.says.com/uploads/brand/avatar/483/347614d45ff75b592f4d5acf030cbbdd.png',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'test',
                      style: TextStyle(
                        fontSize: 18,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ORDER #${widget.order.id}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: scheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.location_city_outlined,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PICK UP ORDER',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${widget.order.pickupAddress}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              'PAYMENT METHOD: ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Paid',
                              // widget.order.isPaid
                              //     ? '\$ ${widget.order.totalPrice} (paid)'
                              //     : '\$ ${widget.order.totalPrice} (Not paid)',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  // : Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           Container(
                  //             width: 40,
                  //             height: 40,
                  //             decoration: BoxDecoration(
                  //               color: scheme.primary.withOpacity(0.2),
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             child: Center(
                  //               child: Icon(
                  //                 Icons.home_work_outlined,
                  //                 color: scheme.primary,
                  //               ),
                  //             ),
                  //           ),
                  //           const SizedBox(width: 15),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   'DELIVER ORDER',
                  //                   style: TextStyle(
                  //                     color: Colors.grey[500],
                  //                     fontSize: 12,
                  //                     fontWeight: FontWeight.w600,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 5),
                  //                 Text(
                  //                   '${widget.order.address.houseNumber} ${widget.order.address.street}',
                  //                   style: const TextStyle(
                  //                     fontWeight: FontWeight.w600,
                  //                     fontSize: 16,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 15),
                  //       Text(
                  //         'COMMENT',
                  //         style: TextStyle(
                  //           color: Colors.grey[500],
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 15),
                  //       GestureDetector(
                  //         onTap: () {
                  //           setState(() {
                  //             isCommentSeeMore = !isCommentSeeMore;
                  //           });
                  //         },
                  //         child: Text(
                  //           widget.order.address.deliveryInstruction ?? '',
                  //           overflow: isCommentSeeMore
                  //               ? TextOverflow.visible
                  //               : TextOverflow.ellipsis,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
              // const SizedBox(height: 15),
              // CustomTextButton(
              //   text: !widget.order.isPickup ? 'Pick Up' : 'Delivered',
              //   onPressed: !widget.order.isPickup
              //       ? widget.pickUpHandler
              //       : widget.deliverHandler,
              //   isDisabled:
              //       !widget.order.isPickup ? false : !widget.order.isNear,
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
