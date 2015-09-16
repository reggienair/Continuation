//Demo1: Apex Asynchronous Callout Framework a.k.a. Continuation
//Single callout to create and Account record
public with sharing class Demo1 {
	static Integer CONTINUATION_CALLOUT_TIMEOUT = 120;  
	
    public  String response {get;set;}
    public  String service {get;set;}
    public  String calloutType {get;set;}
    public  String serviceResult {get;set;}
    public  long startTime {get;set;}
    public  long endTime {get;set;}
    public  long latency {get;set;}
    public  long responseSize {get;set;}
    
    public  Id accountId {get;set;}

	public AsyncDemoWS.createAccountResponse_elementFuture createAccountCallout;

	//Initialize variables
	public void init() {
        startTime = System.currentTimeMillis();
        calloutType = 'Single Callout';
        service = 'CreateAccount';
        serviceResult = 'Newly Created Account Id';
	}

	//Invokes the Continuation callout
	public Continuation makeSOAPDemoCallout() {
		init();
        Continuation continuationObject = new Continuation(CONTINUATION_CALLOUT_TIMEOUT);
        continuationObject.continuationMethod = 'getSOAPDemoCalloutResult';
        AsyncDemoWS.AsyncDemoWebService demoWebService = new AsyncDemoWS.AsyncDemoWebService();
        DemoWS.SessionHeader_element sessionHeader = new DemoWS.SessionHeader_element();
        sessionHeader.sessionId = DemoUtil.getServiceCred();
        demoWebService.SessionHeader = sessionHeader;
        createAccountCallout =  demoWebService.beginCreateAccount(continuationObject, 'Apex Asynchronous Callout Framework');
        return continuationObject;
	}

	//Process Callout Response
	public Object getSOAPDemoCalloutResult() {
        response = createAccountCallout.getValue();
        accountId =  response;
        complete();
        return null;
	}
	
	//Complete the variable computations
	public void complete() {
		HttpResponse responseObject = Continuation.getResponse(DemoUtil.getLabel(createAccountCallout));
		response = responseObject.getBody();
		
        endTime = System.currentTimeMillis();
        latency = endTime - startTime;
        responseSize = response.length();
	}

}