select Campaign from claim where claim_number in (
'C-10763992','C-10764284', -- retrofit labor
'C-10764198','C-10764288', --	retrofit material
'C-10764292', 'C-10764338' -- rebate
);
 -- service_information
 -- for_dealer
 -- campaign
 
 select * from campaign;
 select * from TWMS_OWNER.Campaign_Service_Detail;
 select * from TWMS_OWNER.Campaign_Attachments; -- nothing
 select * from TWMS_OWNER.Campaign_Coverage; -- not much to use
 select * from TWMS_OWNER.Campaign_Coverage_Items; -- m2m table links to items
 select * from TWMS_OWNER.Campaign_Gl_Details; -- m2m to GL_DETAILS;
 select * from TWMS_OWNER.Campaign_Labor_Detail; -- details about labor
 select * from TWMS_OWNER.Campaign_Labor_Limits;  -- m2m to campaign labor_detail
 select * from TWMS_OWNER.Campaign_Misc_Parts; -- nothing
 select * from TWMS_OWNER.Campaign_Nonoem_Parts; -- m2m to non-oem parts
 select * from TWMS_OWNER.Campaign_Notification; -- mostly links to campaign, items, etc.
 select * from TWMS_OWNER.Campaign_Oem_Parts; -- m2m to oem parts
 select * from TWMS_OWNER.Campaign_Range_Coverage; -- nothing
 select * from TWMS_OWNER.Campaign_Ranges; -- nothing
 select * from TWMS_OWNER.Campaign_Section_Price; -- sets prices, and m2m to campain_service_detail
 select * from TWMS_OWNER.Campaign_Serial_Numbers; -- links to serial numbers
 select * from TWMS_OWNER.Campaign_Service_Detail; -- m2m to travel_detials
 select * from TWMS_OWNER.Campaign_Sno_Coverage; -- just a bunch of IDs
 select * from TWMS_OWNER.Campaign_Sno_Coverage_Sno; -- m2m serial number to campaign_sno_coverage
 select * from TWMS_OWNER.Campaign_Status; -- nothing
 select * from TWMS_OWNER.Campaign_Travel_Detail; -- a whole lot of nulls
 select * from TWMS_OWNER.Campaigns_In_Contract; -- nothing
 select * from TWMS_OWNER.Campaigns_In_Related_Campaign; -- nothing
 
 select CODE, DESCRIPTION, FROM_DATE, TILL_DATE, D_Created_On, D_UPDATED_ON, D_ACTIVE, STATUS, CAUSAL_PART, FINANCIAL_BUDGET, AMOUNT_UTILIZED, FINANCIAL_CURRENCY
 FROM campaign
 Where Business_Unit_Info = 'HVAC TCP';
 