﻿/*
	The MIT License
	 
	Copyright (c) 2012 Robert M. Hall, II, Inc. dba Feasible Impossibilities
	http://www.impossibilities.com/
	 
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	 
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

// Version 0.1
package com.impossibilities.runway.leapmotion 
{

	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class CustomSocket extends Socket
	{

		private var response:String;
		private var uiRef:Object;
		private var timeoutValue:Number = 5000;
		private var bytes:ByteArray = new ByteArray;
		private var data_arr:Array;

		public function CustomSocket(container:Object, host:String=null, port:uint=0)
		{
			super();
			uiRef = container;
			configureListeners();
			if ((host && port))
			{
				timeout = timeoutValue;
				super.connect(host,port);
			}
		}

		private function socketTimeout():void
		{
			trace("Socket Connection Timeout");
			close();
		}

		private function configureListeners():void
		{
			addEventListener(Event.CLOSE,closeHandler);
			addEventListener(Event.CONNECT,connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA,socketDataHandler);
		}

		private function writeln(str:String):void
		{
			try
			{
				writeUTFBytes(str);
			}
			catch (e:IOError)
			{
				trace(e);
			}
		}
		
		private function readResponse(totalBytes):void
		{
			var str:String = readUTFBytes(bytesAvailable);
			uiRef.acceptData(str);
		}

		public function sendCommand(cmd:String):void
		{
			writeln(cmd);
		}

		private function closeHandler(event:Event):void
		{
			trace(("closeHandler: " + event));
			trace(response.toString());
		}

		private function connectHandler(event:Event):void
		{
			trace(("connectHandler: " + event));
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			trace(("ioErrorHandler: " + event));
			if (event.errorID == 2031)
			{
				trace("Socket failed to connect");
			}
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace(("securityErrorHandler: " + event));
		}

		private function socketDataHandler(event:ProgressEvent):void
		{
			//trace("socketDataHandler: " + event);
			readResponse(event.bytesTotal);
		}

		// Helper functions for various data - most unused for this particular Leap project
		// that is dealing with plain text/socket data
		private function dec2hex(dec:String):String
		{
			var hex:String = "";//"0x";
			var bytes:Array = dec.split(" ");
			var i:uint = 0;
			for (i = 0; i < bytes.length; i++)
			{
				hex +=  d2h(int(bytes[i]));
			}
			return hex;
		}

		private function d2h(d:int):String
		{
			var c:Array = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
			if ((d > 255))
			{
				d = 255;
			}
			var l:int = d / 16;
			var r:int = d % 16;
			return c[l] + c[r];
		}

		private function hex2dec(hex:String):String
		{
			var bytes:Array = [];
			while (hex.length > 2)
			{
				var byte:String = hex.substr(-2);
				hex = hex.substr(0,hex.length - 2);
				bytes.splice(0,0,int(("0x" + byte)));
			}
			return bytes.join(".");
		}

		private function padString(str:String,len:Number,pad:String):String
		{
			var newStr:String = "";
			if (str.length < len)
			{
				newStr = pad + str;
			}
			return newStr;
		}

	}
}