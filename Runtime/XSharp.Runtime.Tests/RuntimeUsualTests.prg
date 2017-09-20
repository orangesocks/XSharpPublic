﻿USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
using XUnit
using XSharp.Runtime


BEGIN NAMESPACE XSharp.Runtime.Tests

	CLASS RuntimeUsualTests

		[Fact];
		METHOD DateTimeTest() as void
			local now as __VODate
			local u   as __Usual
		    now := (__VODate)System.DateTime.Now 
			u := __Usual{now}
			var s := u:ToString()
			Assert.Equal(now:ToString(),u:ToString())
		RETURN

	END CLASS
END NAMESPACE // XSharp.Runtime.Tests