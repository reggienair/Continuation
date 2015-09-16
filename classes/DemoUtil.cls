public with sharing class DemoUtil {

	//Returns the credential for login
	public static String getServiceCred() {
    	DFDemo__c demo = DFDemo__c.getInstance(UserInfo.getProfileId());
    	return demo.sessionid__c;
	}
	
	//returns the Continuation label for this callout
	public static String getLabel(Object continuationWS) {
		String continuation = String.valueOf(continuationWS);
		List<String> labels = continuation.split('=');
		String label  = labels.get(1);
		label = label.substring(0, label.length()-1);
		return label;
	}

}