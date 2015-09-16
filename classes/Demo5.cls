//Demo5: Apex Asynchronous Callout Framework a.k.a. Continuation
//Chained & Parallel callouts to create and Account, Contact and Opportunity records
public with sharing class Demo5 {
	static Integer CONTINUATION_CALLOUT_TIMEOUT = 120;  
	AsyncDemoWS.createAccountResponse_elementFuture createAccountCallout;
	AsyncDemoWS.createContactResponse_elementFuture createContactCallout;
	AsyncDemoWS.createOpportunityResponse_elementFuture createOpportunityCallout;

    public  String response {get;set;}
    public  String service {get;set;}
    public  String calloutType {get;set;}
    public  String serviceResult {get;set;}
    public  long startTime {get;set;}
    public  long endTime {get;set;}
    public  long latency {get;set;}
    public  long responseSize {get;set;}

	public HttpResponse htmlResponse1 {get;set;}
	public HttpResponse htmlResponse2 {get;set;}
	public HttpResponse htmlResponse3 {get;set;}

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
        response = createAccountCallout.getValue();
        
        //Now create another callout for contact creation with the received Account ID
        Continuation continuationObject = new Continuation(CONTINUATION_CALLOUT_TIMEOUT);
        continuationObject.continuationMethod = 'processContactCreationResponse';
        AsyncDemoWS.AsyncDemoWebService demoWebService = new AsyncDemoWS.AsyncDemoWebService();
        DemoWS.SessionHeader_element sessionHeader = new DemoWS.SessionHeader_element();
        sessionHeader.sessionId = getServiceCred();
        demoWebService.SessionHeader = sessionHeader;

        //Invoke the Continuation Callout-2     
        //Now create another callout for contact creation with the received Account ID
        createContactCallout =  demoWebService.beginCreateContact(continuationObject, 'Asynchronous','Callout', response);
        //Invoke the Continuation Callout-3        
        //Now create another callout for Opportunity creation with the received Account ID
        createOpportunityCallout =  demoWebService.beginCreateOpportunity(continuationObject, 'Asynchronous Opportunity', response);
        		response += ',===**'+continuationObject.getRequests();
        
        return continuationObject;
	}
	
	public Object processContactCreationResponse() {
		//response += ', createContactCallout='+String.valueOf(createContactCallout);
		//response += ', createOpportunityCallout='+String.valueOf(createOpportunityCallout);
		/*HttpResponse responseObject = Continuation.getResponse('Continuation-2');
		response += ',\n\n*****\n'+responseObject.getBody()+'\n\n*****\n';
		responseObject = Continuation.getResponse('Continuation-3');
		response += ', '+responseObject.getBody();
		*/
        response += ',\n ContactId='+createContactCallout.getValue();
        response += ',\n OpportunityId= '+createOpportunityCallout.getValue();
        
        //htmlResponse2 = Continuation.getResponse(createContactCallout.label());
        
        endTime = System.currentTimeMillis();
        latency = endTime - startTime;
        responseSize = response.length();
		return null;		
	}

	/*
	public Object processContactCreationResponse() {
		HttpResponse responseObject = Continuation.getResponse('Continuation-2');
		response += ',\n\n*****\n'+responseObject.getBody()+'\n\n*****\n';
		responseObject = Continuation.getResponse('Continuation-3');
		response += ', '+responseObject.getBody();
		
        response += ', =='+Continuation.getResponse('Continuation-2')+'==';
        //response += ', '+createOpportunityCallout.getValue();
        response += ' '+createContactCallout.getValue();
        //response += ', '+ makeContactCallout.getValue()+', '+makeContactCallout2.getValue();
        
        //endTime = System.currentTimeMillis();
        //latency = endTime - startTime;
        //responseSize = response.length();
		//return null;		
	}*/

	//Returns the  web service login credential
	private static String getServiceCred() {
    	DFDemo__c demo = DFDemo__c.getInstance(UserInfo.getProfileId());
    	return demo.sessionid__c;
	}
}