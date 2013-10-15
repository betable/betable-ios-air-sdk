package com.betable.sdk.error
{
	public class SDKError extends Error
	{
		public function SDKError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}