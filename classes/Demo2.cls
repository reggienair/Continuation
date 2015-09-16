//Demo2: Apex Asynchronous Callout Framework a.k.a. Continuation
//Chained callouts to create and Account and Contact records
public with sharing class Demo2 {
	static Integer CONTINUATION_CALLOUT_TIMEOUT = 120;  
	AsyncDemoWS.createAccountResponse_elementFuture createAccountCallout;
	AsyncDemoWS.createContactResponse_elementFuture makeContactCallout;

    private  String response {get;set;}
    public  String service {get;set;}
    public  String calloutType {get;set;}
    public  String serviceResult {get;set;}
    public  long startTime {get;set;}
    public  long endTime {get;set;}
    public  long latency {get;set;}
    public  long responseSize {get;set;}

    public  Id accountId {get;set;}
    public  Id contactId {get;set;}

    public  String response1 {get;set;}
    public  String response2 {get;set;}

	//Initialize variables
	public void init() {
        startTime = System.currentTimeMillis();
        calloutType = 'Chained Callout';
        service = '(1) CreateAccount (2) CreateContact';
        serviceResult = 'Newly Created Account and Contact Ids';
	}
	
	//Invoke the Continuation Callout-1
	public Continuation makeSOAPDemoCallout() {
		init();
        Continuation continuationObject = new Continuation(CONTINUATION_CALLOUT_TIMEOUT);
        continuationObject.continuationMethod = 'processAccountCreationResponse';
        AsyncDemoWS.AsyncDemoWebService demoWebService = new AsyncDemoWS.AsyncDemoWebService();
        DemoWS.SessionHeader_element sessionHeader = new DemoWS.SessionHeader_element();
        sessionHeader.sessionId = DemoUtil.getServiceCred();
        demoWebService.SessionHeader = sessionHeader;
        createAccountCallout =  demoWebService.beginCreateAccount(continuationObject, 'Apex Asynchronous Callout Framework');
        return continuationObject;
	}

	//Process response from theContinuation Callout-1
	public Object processAccountCreationResponse() { 
		//Get the response from createContact call.       
        response = createAccountCallout.getValue();
        accountId = createAccountCallout.getValue();
        
        //Now create another callout for contact creation with the received Account ID
        Continuation continuationObject = new Continuation(CONTINUATION_CALLOUT_TIMEOUT);
        continuationObject.continuationMethod = 'processContactCreationResponse';
        AsyncDemoWS.AsyncDemoWebService demoWebService = new AsyncDemoWS.AsyncDemoWebService();
        DemoWS.SessionHeader_element sessionHeader = new DemoWS.SessionHeader_element();
        sessionHeader.sessionId = DemoUtil.getServiceCred();
        demoWebService.SessionHeader = sessionHeader;
        
        //Invoke the Continuation Callout-2        
        makeContactCallout =  demoWebService.beginCreateContact(continuationObject, 'Asynchronous','Callout', response);

		HttpResponse responseObject = Continuation.getResponse(DemoUtil.getLabel(String.valueOf(createAccountCallout)));
		response1 = responseObject.getBody();
        return continuationObject;
	}
	
	//Process response from theContinuation Callout-2
	public Object processContactCreationResponse() {
        response += ', '+ makeContactCallout.getValue();
        contactId = makeContactCallout.getValue();

		HttpResponse responseObject = Continuation.getResponse(DemoUtil.getLabel(String.valueOf(makeContactCallout)));
		response2 = responseObject.getBody();

        complete();
		return null;		
	}
	
	//Complete the variable computations
	public void complete() {
        endTime = System.currentTimeMillis();
        latency = endTime - startTime;
        responseSize = response1.length()+response2.length();
	}


}