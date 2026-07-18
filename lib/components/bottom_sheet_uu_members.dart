// Project imports:
import '../imports.dart';

class BottomSheetUUMembers extends StatelessWidget {
  final List<UUMemberModel> members;
  final Function(UUMemberModel)? onSelect;

  const BottomSheetUUMembers({super.key, required this.members, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.all(kHorizontalPadding).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'UUPay账号',
              fontSize: kFont15,
              fontWeight: FontWeight.w600,
            ),
            16.heightSpace,
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24).r,
                child: Center(
                  child: AppText(
                    '暂无可选账号',
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: members.length,
                  separatorBuilder: (context, index) => 10.heightSpace,
                  itemBuilder: (context, index) {
                    final UUMemberModel member = members[index];
                    final bool isActive = member.isActive == true;

                    return InkWellWrapper(
                      onTap: isActive
                          ? null
                          : () {
                              AppNavigator.pop(context);
                              onSelect?.call(member);
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ).r,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.lightPrimaryColor
                              : AppColors.lightGreyBackgroundColor,
                          borderRadius: BorderRadius.circular(14).r,
                          border: Border.all(
                            color: isActive
                                ? AppColors.primaryNoContextColor
                                : AppColors.greyLightColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    '${member.name ?? '-'} - ${member.bank ?? '-'}',
                                    fontSize: kFont14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryTextColor,
                                  ),
                                  4.heightSpace,
                                  AppText(
                                    '账号: ${member.accountNumber ?? '-'}',
                                    fontSize: kFont12,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ).r,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNoContextColor,
                                  borderRadius: BorderRadius.circular(12).r,
                                ),
                                child: AppText(
                                  '使用中',
                                  fontSize: kFont11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.whiteColor,
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20.sp,
                                color: AppColors.secondaryTextColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
