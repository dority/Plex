<cfcomponent name="utility">
	
	<cfset VARIABLES.shows = {
		dropPath = "\\READYNAS2\videos\Drops\tvDrops\",
		maxDLAttempts = 3,
		deleteIncompleteFiles = True
	}>

	<cffunction name="urlExists" access="public" output="no" returntype="boolean">
		<cfargument name="url" type="string" required="yes">
		
		<!--- Attempt to retrieve the URL --->
		<cftry>
			<cfhttp method="head" url="#ARGUMENTS.url#" throwonerror="yes" timeout="2" />
			
			<cfcatch type="any">
				<cfreturn False /><!--- Failed --->
			</cfcatch>
		</cftry>
		
		<cfreturn True /><!--- Success --->
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
	
	<cffunction name="validFolderName" access="private" returnType="String" output="false" hint="make sure the folder has not reserved characters">
        <cfargument name="folderName" type="string" required="true" default="">
        
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, CHR(34), "", "ALL")> <!--- Double Quotes --->
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "*", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "/", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "\", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, " : ", " - ", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, ": ", " - ", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, ":", " - ", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "<", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, ">", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "?", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "|", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, CHR(35), "", "ALL")> <!--- Pound Sign 0--->
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "{", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "}", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "'", "", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "  ", " ", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "  ", " ", "ALL")>
        <cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, "  ", " ", "ALL")>
        <!---<cfset ARGUMENTS.foldername = Replace(ARGUMENTS.folderName, ".", "_", "ALL")>--->
        
        <cfif ListFindNoCase("PRN,AUX,NUL,LPT1,COM1,CON", ARGUMENTS.folderName)>
              <cfset ARGUMENTS.folderName ="Folder">
        </cfif>
        
        <cfreturn ARGUMENTS.folderName>
	</cffunction>
	
	<cffunction name="validFileName" access="private" returnType="String" output="false" hint="make sure the folder has not reserved characters">
        <cfargument name="fileName" type="string" required="true" default="">
        
        <cfset LOCAL.ext = ListLast(ARGUMENTS.fileName, '.')>
        <cfset ARGUMENTS.fileName = Reverse(ReplaceNoCase(Reverse(ARGUMENTS.fileName), Reverse('.' & LOCAL.ext), ''))>
        
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, CHR(34), "", "ALL")> <!--- Double Quotes --->
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "*", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "/", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "\", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, " : ", " - ", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, ": ", " - ", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, ":", " - ", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "<", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, ">", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "?", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "|", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, CHR(35), "", "ALL")> <!--- Pound Sign 0--->
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "{", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "}", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "'", "", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "  ", " ", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "  ", " ", "ALL")>
        <cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, "  ", " ", "ALL")>
        
        <cfif ListFindNoCase("PRN,AUX,NUL,LPT1,COM1,CON", ARGUMENTS.fileName)>
              <cfset ARGUMENTS.fileName ="Folder">
        </cfif>
        
        <cfset ARGUMENTS.fileName &= '.' & LOCAL.ext>
        
        <cfreturn ARGUMENTS.fileName>
	</cffunction>
	
	
</cfcomponent>
