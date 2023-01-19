parameters{
	KIOSK_Container as string,
	KIOSK_endpoint as string
}
source(output(
		Business_ID as string,
		Business_Description as string,
		Sub_Function_ID as string,
		Sub_Function_Description as string,
		Service_Line_ID as string,
		Service_Line_Description as string,
		Geography_ID as string,
		Geography_Description as string,
		Member_Firm as string,
		Member_Firm_Description as string,
		Value_Type as string,
		Value_Type_Desc as string,
		Fiscal_Year as string,
		Fiscal_Period as string,
		Fiscal_Period_Desc as string,
		Levels as string,
		Hours as string,
		Headcounts as string
	),
	allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false) ~> KioskExtractFile
KioskExtractFile aggregate(groupBy(Business_ID),
	Row_Count = count(Business_ID),
		TC1_Total_Hours = round(sum( iifNull(Hours, 0.0) ) , 2),
		TC2_Total_Headcounts = round(sumIf( Levels !='Total Client Service Headcounts' , iifNull(Headcounts, 0.0)  ),2),
		TC3_Total_Client_Service_Headcounts = round(sumIf( Levels == 'Total Client Service Headcounts' ,   iifNull(Headcounts, 0.0)),2)) ~> aggregate1
aggregate1 sink(allowSchemaDrift: true,
	validateSchema: false,
	partitionFileNames:['KIOSK_Auditing.csv'],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	partitionBy('hash', 1)) ~> AuditingSNKBlob