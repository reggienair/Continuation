//Demo3: Apex Asynchronous Callout Framework a.k.a. Continuation
//Chained & Parallel callouts to create and Account, Contact and Opportunity records
public with sharing class Demo3 {
	static Integer CONTINUATION_CALLOUT_TIMEOUT = 120;  
	AsyncDemoWS.createAccountResponse_elementFuture createAccountCallout;
	AsyncDemoWS.createContactResponse_elementFuture createContactCallout;
	AsyncDemoWS.createOpportunityResponse_elementFuture createOpportunityCallout;

    public  String response1 {get;set;}
    public  String response2 {get;set;}
    public  String response3 {get;set;}
    public  String service {get;set;}
    public  String calloutType {get;set;}
    public  String serviceResult {get;set;}
    public  long startTime {get;set;}
    public  long endTime {get;set;}
    public  long latency {get;set;}
    public  long responseSize {get;set;}

    public  Id accountId {get;set;}
    public  Id contactId {get;set;}
    public  Id opportunityId {get;set;}
    private  String response {get;set;}

	//Initialize variables
	public void init() {
        startTime = System.currentTimeMillis();
        calloutType = 'Chained Callouts';
        service = '(1) CreateAccount (2) CreateContact, CreateOpportunity';
        serviceResult = 'Newly Created Account, Contact and Opportunity Ids';
	}
	
	
	//Invoke the Continuation Callout-1
	public Continuation makeSOAPDemoCallout() {
		init();
        Continuation continuationObject = new Continuation(CONTINUATION_CALLOUT_TIMEOUT);
        continuationObject.continuationMethod = 'processAccountCreationResponse';
        AsyncDemoWS.AsyncDemoWebService demoWebService = new AsyncDemoWS.AsyncDemoWebService();
        DemoWS.SessionHeader_element sessionHeader = new DemoWS.SessionHeader_element();
        sessionHeader.sessionId = getServiceCred();
        demoWebService.SessionHeader = sessionHeader;
        createAccountCallout =  demoWebService.beginCreateAccount(continuationObject, 'Apex Asynchronous Callout Framework');
        return continuationObject;
	}

	//Process response from theContinuation Callout-1
	//Invoke Callout-2  and Callout-3 in parallel
	public Object processAccountCreationResponse() { 
		//Get the response from createContact call.       
        accountId = createAccountCallout.getValue();
        
        //Now create another callout for contact creation with the received Account ID
        Continuation continuationObject = new Continuation(CONTINUATION_CALLOUT_TIMEOUT);
        continuationObject.continuationMethod = 'processContactCreationResponse';
        AsyncDemoWS.AsyncDemoWebService demoWebService = new AsyncDemoWS.AsyncDemoWebService();
        DemoWS.SessionHeader_element sessionHeader = new DemoWS.SessionHeader_element();
        sessionHeader.sessionId = getServiceCred();
        demoWebService.SessionHeader = sessionHeader;

		HttpResponse responseObject = Continuation.getResponse(DemoUtil.getLabel(String.valueOf(createAccountCallout)));
		response1 = responseObject.getBody();

        //Invoke the Continuation Callout-2     
        //Now create another callout for contact creation with the received Account ID
        createContactCallout =  demoWebService.beginCreateContact(continuationObject, 'Asynchronous','Callout', accountId);
        //Invoke the Continuation Callout-3        
        //Now create another callout for Opportunity creation with the received Account ID
        createOpportunityCallout =  demoWebService.beginCreateOpportunity(continuationObject, 'Asynchronous Opportunity', accountId);
        
        response = String.valueOf(createAccountCallout);
        return continuationObject;
	}
	
	public Object processContactCreationResponse() {
		response += String.valueOf(createContactCallout);
		response += String.valueOf(createOpportunityCallout);
		
		HttpResponse responseObject = Continuation.getResponse(DemoUtil.getLabel(String.valueOf(createContactCallout)));
		response2 = responseObject.getBody();
		responseObject = Continuation.getResponse(DemoUtil.getLabel(String.valueOf(createOpportunityCallout)));
		response3 = responseObject.getBody();
		
		contactId = createContactCallout.getValue();
		opportunityId = createOpportunityCallout.getValue();
		complete();
		return null;		
	}

	//Complete the variable computations
	public void complete() {
        endTime = System.currentTimeMillis();
        latency = endTime - startTime;
        responseSize = response1.length()+response2.length()+response3.length();
	}

	//Returns the  web service login credential
	private static String getServiceCred() {
    	DFDemo__c demo = DFDemo__c.getInstance(UserInfo.getProfileId());
    	return demo.sessionid__c;
	}
}