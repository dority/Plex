<cfcomponent name="servers" extends="utility">
	
	<!--- https://www.shodan.io/search?query=CherryPy%2F5.1.0%2Fhome&page=1 --->
	<!--- CherryPy/5.1.0 --->
		
	<cffunction name="GetServers" access="public" returnType="query" output="true">
		<cfargument name="URL" type="struct">				
		
		<cfset LOCAL.tautulli = {}>
		
		<cfif IsDefined('ARGUMENTS.URL.ip')>
			<cfset LOCAL.tautulli.ip = ARGUMENTS.URL.ip>
		</cfif>
		
		<cfif IsDefined('ARGUMENTS.URL.port')>
			<cfset LOCAL.tautulli.port = ARGUMENTS.URL.port>
		<cfelse>
			<cfset LOCAL.tautulli.port = "8181"><!--- Default --->
		</cfif>		

		<!--- Check If Server Already Logged --->
		<cfquery name="LOCAL.qExistingServer" datasource="Plex">
			SELECT *
			FROM Servers WITH (NOLOCK)
			WHERE [urlTautulli] LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#LOCAL.tautulli.ip#%">
		</cfquery>
		
		<!--- Server Already Exists --->
		<cfif (LOCAL.qExistingServer.recordcount GT 0)>
			<cfset LOCAL.qServer = LOCAL.qExistingServer>
		<cfelse>
			<cfset LOCAL.start = GetTickCount()>
			
			<cfset LOCAL.tautulli.url = 'http://' & LOCAL.tautulli.ip & ':' & LOCAL.tautulli.port & '/settings#chr(35)#tab_tabs-5'>

			<cfset LOCAL.tautulli = GetTautulliSettings(
				tautulli = LOCAL.tautulli
			)>

			<cfset LOCAL.pms = {}>
			
			<!--- Get PMS Server Name --->
			<cfset LOCAL.pms.name = Trim(ListLast(GetHTMLTagValue(LOCAL.tautulli.settings, 'title'), '|'))>
			
			<!--- Get PMS Server IP --->
			<cfset LOCAL.pms.ip = Trim(GetHTMLAttributeValue(LOCAL.tautulli.settings, 'id="pms_ip" name="pms_ip"'))>
			<!--- Tatulli/PlexPy Setup To Local Address, Assume PMS IP Is Same As Tatulli/PlexPy --->
			<cfif (Left(LOCAL.pms.ip, 3) EQ '192')
				OR (Left(LOCAL.pms.ip, 3) EQ '10.')
				OR (LOCAL.pms.ip EQ '127.0.0.1')
				OR (LOCAL.pms.ip EQ 'LOCALHOST')
				OR (ListLen(LOCAL.pms.ip, '.') LT 4)>
				<cfset LOCAL.pms.ip = LOCAL.tautulli.ip>
			</cfif>
			
			<!--- Get PMS Server Port --->
			<cfset LOCAL.pms.port = GetHTMLAttributeValue(LOCAL.tautulli.settings, 'id="pms_port" name="pms_port"')>
			
			<!--- Get PMS Token --->
			<cfset LOCAL.pms.token = GetHTMLAttributeValue(LOCAL.tautulli.settings, 'id="pms_token" name="pms_token"')>			
			<cfset LOCAL.pms.tokenStr = 'X-Plex-Token=' & LOCAL.pms.token>
		
			<cfset LOCAL.pms.url = 'http://' & LOCAL.pms.ip & ':' & LOCAL.pms.port>		
			<cfset LOCAL.pms.urlLibraries =  LOCAL.pms.url & '/library/sections?' & LOCAL.pms.tokenStr>			
			<!--- DEBUG: Output Link Listing Libraries --->
			<!---
			<cfoutput>
			<a href="#urlLibrary#" target="_blank">#urlLibrary#</a><br><br></cfoutput><cfabort>
			--->
			
			
			<!--- Log Server Data To DB --->
			<cfquery datasource="Plex" result="LOCAL.qResult">
				INSERT INTO Servers 
				(
					[serverName], 
					[ip], 
					[port], 
					[token],
					[urlTautulli],
					[urlLibraries],
					[responseTime],
					[active]
				)
				VALUES 
				(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.pms.name#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.pms.ip#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.pms.port#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.pms.token#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.tautulli.url#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.pms.urlLibraries#">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCAL.tautulli.responseTime#">,
					<cfqueryparam cfsqltype="CF_SQL_TINYINT" value="1">
				)
			</cfquery>
			
			<cfset LOCAL.serverID = LOCAL.qResult.generatedkey>
			
			<!--- Create Fresh Query Object With Latest Server Data --->
			<cfquery name="LOCAL.qServer" datasource="Plex">
				SELECT *
				FROM Servers WITH (NOLOCK)
				WHERE [serverID] = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOCAL.serverID#">
			</cfquery>
		</cfif>			
	
		<cfreturn LOCAL.qServer>
	</cffunction>
	
	<cffunction name="GetTautulliSettings" access="public" returnType="struct" output="true">
		<cfargument name="tautulli" type="struct">
	
		<cfset LOCAL.start = GetTickCount()>
		
		<cftry>
			<cfhttp url="#ARGUMENTS.tautulli.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no" result="LOCAL.result"/>
		
			<cfcatch>
				<cfoutput>A connection could not be established with <a href="#ARGUMENTS.tautulli.url#">#ARGUMENTS.tautulli.url#</a></cfoutput>
				<cfabort>
			</cfcatch>
		</cftry>
		
		<cfif (LOCAL.result.responseHeader.Status_Code NEQ 200)>
			<cfdump var="Error connecting to Tautulli" abort>
		<cfelse>
			<cfset ARGUMENTS.tautulli.settings =LOCAL.result.fileContent>
		</cfif>
		
		<cfset LOCAL.finish = GetTickCount()>
		
		<cfset ARGUMENTS.tautulli.responseTime = (LOCAL.finish -  LOCAL.start)>
		
		<cfreturn ARGUMENTS.tautulli>
	</cffunction>
	
	<cffunction name="GetLibraries" access="public" returnType="string" output="true">
		<cfargument name="qServer" type="query">				
		
		<cfhttp url="#ARGUMENTS.qServer.urlLibraries#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no" result="LOCAL.result"/>
		
		<cfif (NOT IsDefined('LOCAL.result.responseHeader.Status_Code')) OR (LOCAL.result.responseHeader.Status_Code NEQ 200)>
			<cfdump var="Error connecting to Libraries" abort>
		<cfelse>
			<cfreturn Trim(LOCAL.result.FileContent)>
		</cfif>
	</cffunction>
	
	
	<cffunction name="GetHTMLAttributeValue" access="public" returnType="any" returnFormat="plain" output="false">
		<cfargument name="scrapeTxt" type="string">
		<cfargument name="identifier" type="string">
		
		<cfset LOCAL.findValue = ''>
		<cfset LOCAL.scrapeTxt = Trim(ARGUMENTS.scrapeTxt)>

		<!--- Find Form Field With Port --->
		<cfset LOCAL.srchTxt = ARGUMENTS.identifier>
		<cfset LOCAL.findPos = FindNoCase(LOCAL.srchTxt, LOCAL.scrapeTxt, 1)>

		<cfif (LOCAL.findPos GT 0)>
			<!--- Strip Prepending Data Before Find Positon --->
			<cfset LOCAL.scrapeTxt = Right(LOCAL.scrapeTxt, (Len(LOCAL.scrapeTxt) - LOCAL.findPos))>
			
			<!--- Find Selected Option For Server Port --->
			<cfset LOCAL.srchTxt = 'value="'>
			<cfset LOCAL.findPos = FindNoCase(LOCAL.srchTxt, LOCAL.scrapeTxt, 1)>
			
			<cfif (LOCAL.findPos GT 0)>
				<!--- Strip Prepending Data Before Token Value --->
				<cfset LOCAL.scrapeTxt = Right(LOCAL.scrapeTxt, (Len(LOCAL.scrapeTxt) - (LOCAL.findPos + Len(LOCAL.srchTxt)) + 1))>

				<cfset LOCAL.srchTxt = '"'>
				<cfset LOCAL.findValue = Trim(Left(LOCAL.scrapeTxt, (FindNoCase(LOCAL.srchTxt, LOCAL.scrapeTxt, 1) - 1)))>
			</cfif>
		</cfif>

		<cfreturn LOCAL.findValue>
	</cffunction>
	
	<cffunction name="GetHTMLTagValue" access="public" returnType="any" returnFormat="plain" output="false">
		<cfargument name="scrapeTxt" type="string">
		<cfargument name="tagName" type="string">
		
		<cfset LOCAL.findValue = ''>
		<cfset LOCAL.scrapeTxt = Trim(ARGUMENTS.scrapeTxt)>
		<cfset LOCAL.srchTxt = Trim(ARGUMENTS.tagName)>
		
		<cfset LOCAL.findPos = FindNoCase('<' & LOCAL.srchTxt & '>', LOCAL.scrapeTxt, 1)>
		
		<cfif (LOCAL.findPos GT 0)>
			<!--- Strip Prepending Data Before Find Positon --->
			<cfset LOCAL.scrapeTxt = Right(LOCAL.scrapeTxt, (Len(LOCAL.scrapeTxt) - LOCAL.findPos - (Len('<' & LOCAL.srchTxt & '>') - 1)))>
			
			<!--- Find End Tag --->
			<cfset LOCAL.srchTxt = '</' & LOCAL.srchTxt & '>'>
			<cfset LOCAL.findPos = FindNoCase(LOCAL.srchTxt, LOCAL.scrapeTxt, 1)>
			
			<cfif (LOCAL.findPos GT 0)>
				<!--- Get String Before End Tag --->
				<cfset LOCAL.findValue = Left(LOCAL.scrapeTxt, (LOCAL.findPos - 1))>
			</cfif>
		</cfif>
		
		<cfreturn LOCAL.findValue>
	</cffunction>
	
</cfcomponent>
