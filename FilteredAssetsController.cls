public with sharing class FilteredAssetsController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssetFromSalesOrderItem(){
        
        List<Asset> assetsFromSalesOrderItem=new List<Asset>();

         List<String> erpWbsId=new List<String>(); 
         List<ERP_WBS__c> erpWbsList=new List<ERP_WBS__c>();
         List<String> wbsErpAssets=new List<String>();
    	
         
         
         /* Get all Sales Order Item where ERP_Item_Category__c is Z003 & Material_Description__c has 4D CBCT in it*/
         List<Sales_Order_Item__c> filteredSalesOrderItems=[select name,id,ERP_WBS__c from Sales_Order_Item__c  where ERP_Item_Category__c like 'Z003' AND Material_Description__c like '%4D_CBCT%' WITH SECURITY_ENFORCED ];
         /* Store ERP_WBS__c field of filteredSalesOrderItems */
         for(Sales_Order_Item__c x:filteredSalesOrderItems)
         {
             erpWbsId.add(x.ERP_WBS__c);
         }
         
         /* If ID of ERP_WBS__c exists in erpWbsId */
        erpWbsList=[select id,name,WBS_Asset__c from ERP_WBS__c where id in :erpWbsId WITH SECURITY_ENFORCED];
         
         /* Add WBS_Asset__c field from erpWbsList to wbsErpAssets*/
        for(ERP_WBS__c assetId:erpWbsList)
 		{
            if(assetId.WBS_Asset__c!=null)
            {
                wbsErpAssets.add(assetId.WBS_Asset__c);
            }
     	
 		}
        /* Fetch Assets Id which exist in wbsErpAssets list & name starts with H19*/
        assetsFromSalesOrderItem=[select id,name,Account_Name__c,Contract_Number__c from asset where id in :wbsErpAssets and name like 'H19%' WITH SECURITY_ENFORCED];
        
        return assetsFromSalesOrderItem;
    
    }
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssetfromQuoteProductPricing(List<Asset> assetsFromSalesOrderItem)
    {
         
       //Input of this function is the output-> Assets returned from getAssetFromSalesOrderItem()
   		List<Asset> inputAsset= assetsFromSalesOrderItem;
        List<String> inputAssetIdList=new List<String>();
        
        List<Asset> assetQuotes=new List<Asset>();
        List<String> assetQuoteIdList=new List<String>();
        
        List<Quote_Product_Pricing__c> quoteWithPartNo=new List<Quote_Product_Pricing__c>();
        List<String> quoteWithPartNoIdList=new List<String>();
        List<Quote_Product_Pricing__c> quoteWithoutPartNo=new List<Quote_Product_Pricing__c>();
        List<String> quoteWithoutPartNoIdList=new List<String>();
        
        List<Asset> filteredAssets=new List<Asset>();
        
        for(Asset a:inputAsset){
            inputAssetIdList.add(a.id);
        }
        
        //Asset which have Service Contract --> Service Contract which have quotes on it
        assetQuotes=[select id,name,Service_Contract__r.Quote__c from Asset where id in:inputAssetIdList and Service_Contract__r.Quote__c!=null WITH SECURITY_ENFORCED];
      	//Store Quote Id in list
        for(Asset a:assetQuotes){
            assetQuoteIdList.add(a.Service_Contract__r.Quote__c);
        }
        
		//Quote Product Pricing where part number is CPC001001203
        quoteWithPartNo=[select Part_Number__c,BMI_Quote__c from Quote_Product_Pricing__c where Part_Number__c='CPC001001203'and  BMI_Quote__c in:assetQuoteIdList WITH SECURITY_ENFORCED];
  		//Add quote id to list which quote has  part number named CPC001001203
        for(Quote_Product_Pricing__c c:quoteWithPartNo){
            quoteWithPartNoIdList.add(c.BMI_Quote__c);
        }
        
        //Quote Product Pricing where part number is not CPC001001203
        quoteWithoutPartNo=[select Part_Number__c,BMI_Quote__c from Quote_Product_Pricing__c where Part_Number__c!='CPC001001203'and  BMI_Quote__c in:assetQuoteIdList WITH SECURITY_ENFORCED];
        //Add quote id to list which quote has no part number named CPC001001203
        for(Quote_Product_Pricing__c c:quoteWithoutPartNo){
            if(!quoteWithPartNoIdList.contains(c.BMI_Quote__c)){
                quoteWithoutPartNoIdList.add(c.BMI_Quote__c);
            }
            
        }
        //Final result
        filteredAssets=[select id,name,Account_Name__c,Contract_Number__c from Asset where id in:inputAssetIdList and Service_Contract__r.Quote__c in:quoteWithoutPartNoIdList WITH SECURITY_ENFORCED];
        System.debug(filteredAssets);

        return filteredAssets;
    }
    @AuraEnabled(cacheable=true)
   	public static List<Asset> getAllFilteredAssets()
    {
        List<Asset> filteredAssets=new List<Asset>();
        List<Asset> assetsFromSalesOrderItem=new List<Asset>();
        assetsFromSalesOrderItem=getAssetFromSalesOrderItem();
        filteredAssets=getAssetfromQuoteProductPricing(assetsFromSalesOrderItem);
        return filteredAssets;
    }
    
}