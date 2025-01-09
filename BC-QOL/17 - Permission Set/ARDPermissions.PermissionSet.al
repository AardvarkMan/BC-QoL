namespace AardvarkLabs;

using AardvarkLabs;

permissionset 50000 ARD_Permissions
{
    Assignable = true;
    Caption = 'AardvarkLabs Permissions', MaxLength = 30;
    Permissions = table ARD_Warranty=X,
        tabledata ARD_Warranty=RMID,
        page ARD_WarrantyCard=X,
        page ARD_WarrantyList=X,
        tabledata ARDWarrantyClaim=RIMD,
        table ARDWarrantyClaim=X,
        codeunit ARDValidateCustomer=X,
        codeunit ARD_WarrantyDateHandler=X,
        page ARD_ItemAPI=X,
        tabledata ARD_Settings=RIMD,
        table ARD_Settings=X,
        codeunit ARD_ClaimResolvedEvent=X,
        codeunit ARD_SettingsManager=X,
        page ARDCustomerClaims=X,
        page ARD_Settings=X;
}