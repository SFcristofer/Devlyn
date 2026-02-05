public with sharing class WrapperLogin {
    public String token;
	public Integer status;

	public static WrapperLogin parse(String json) {
		return (WrapperLogin) System.JSON.deserialize(json, WrapperLogin.class);
	}
}