<cfcomponent name="movies" extends="utility">
	
	
	<cffunction name="GetShows" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="url" type="string">
				
		
		<cfset LOCAL.qTheirShows = QueryNew('libraryTitle,showTitle,showkey')><!--- Declare --->
		
		<cfhttp url="#ARGUMENTS.url#" method="GET" throwOnError="Yes" getasbinary="no"/>
		
		<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
		
		<!--- Parse Data Structure To Query Object --->
		<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
			<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
				<cfset LOCAL.aShows = LOCAL.xmlLibrary.MediaContainer.XMLChildren>

				<cfif IsArray(LOCAL.aShows)>
					<cfloop array="#LOCAL.aShows#" index="LOCAL.xmlShow">
						
						<cfif StructKeyExists(LOCAL.xmlShow, 'XmlAttributes')>
							<cfif StructKeyExists(LOCAL.xmlShow.XmlAttributes, 'title')>
								<cfset LOCAL.showTitle = LOCAL.xmlShow.XmlAttributes.title>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlShow.XmlAttributes, 'key')>
								<cfset LOCAL.showKey = LOCAL.xmlShow.XmlAttributes.key>
							</cfif>
						</cfif>
						
						<cfset QueryAddRow(LOCAL.qTheirShows)>
										
						<cfset QuerySetCell(LOCAL.qTheirShows, 'libraryTitle', ARGUMENTS.libraryTitle)>
						<cfset QuerySetCell(LOCAL.qTheirShows, 'showTitle', LOCAL.showTitle)>
						<cfset QuerySetCell(LOCAL.qTheirShows, 'showkey', LOCAL.showKey)>
					</cfloop>
					
					
				</cfif>			
				
			</cfif>	
		</cfif>
	
		<cfreturn LOCAL.qTheirShows>
	</cffunction>
	
	<cffunction name="GetSeasons" access="public" returnType="query" output="true">
		<cfargument name="qServer" type="query">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="qTheirShows" type="query">
		
		<cfset LOCAL.pmsURL = 'http://' & ARGUMENTS.qServer.ip & ':' & ARGUMENTS.qServer.port>
		<cfset LOCAL.pmsTokenStr = 'X-Plex-Token=' & ARGUMENTS.qServer.token>		
				
		<cfset LOCAL.qTheirSeasons = QueryNew('libraryTitle,showTitle,showKey,seasonTitle,seasonKey')><!--- Declare --->
		
		<cfloop query="ARGUMENTS.qTheirShows">
			<cfset LOCAL.url = LOCAL.pmsURL & ARGUMENTS.qTheirShows.showKey[ARGUMENTS.qTheirShows.currentRow] & '?' & LOCAL.pmsTokenStr>
			
			<cfhttp url="#LOCAL.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
			<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
			
			<!--- Parse Data Structure To Query Object --->
			<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
				<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XmlAttributes')>
					<cfset LOCAL.aSeasons = LOCAL.xmlLibrary.MediaContainer.XMLChildren>
					
					<cfif IsArray(LOCAL.aSeasons)>
						<cfloop array="#LOCAL.aSeasons#" index="LOCAL.xmlSeason">							
							<cfif StructKeyExists(LOCAL.xmlSeason, 'XmlAttributes')>
								<cfif (LOCAL.xmlSeason.XmlAttributes.title NEQ 'All episodes')>
									<cfset QueryAddRow(LOCAL.qTheirSeasons)>
									
									<cfset QuerySetCell(LOCAL.qTheirSeasons, 'libraryTitle', ARGUMENTS.libraryTitle)>
									<cfset QuerySetCell(LOCAL.qTheirSeasons, 'showTitle', ARGUMENTS.qTheirShows.showTitle)>
									<cfset QuerySetCell(LOCAL.qTheirSeasons, 'showKey', ARGUMENTS.qTheirShows.showKey)>
									
									<cfif StructKeyExists(LOCAL.xmlSeason.XmlAttributes, 'title')>
										<cfset QuerySetCell(LOCAL.qTheirSeasons, 'seasonTitle', LOCAL.xmlSeason.XmlAttributes.title)>
									</cfif>
									<cfif StructKeyExists(LOCAL.xmlSeason.XmlAttributes, 'key')>
										<cfset QuerySetCell(LOCAL.qTheirSeasons, 'seasonKey', LOCAL.xmlSeason.XmlAttributes.key)>
									</cfif>
								</cfif>	
							</cfif>							
						</cfloop>
					</cfif>
				</cfif>	
			</cfif>
		</cfloop>
	
		<cfreturn LOCAL.qTheirSeasons>
	</cffunction>
	
	<cffunction name="GetEpisodes" access="public" returnType="query" output="true">
		<cfargument name="qServer" type="query">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="qTheirSeasons" type="query">
										
		<cfset LOCAL.pmsURL = 'http://' & ARGUMENTS.qServer.ip & ':' & ARGUMENTS.qServer.port>
		<cfset LOCAL.pmsTokenStr = 'X-Plex-Token=' & ARGUMENTS.qServer.token>				

		<cfset LOCAL.qTheirEpisodes = QueryNew('urlInfo,urlDownload,libraryTitle,showTitle,showKey,seasonTitle,seasonKey,episodeNum,episodeTitle,episodeKey,videoResolution,container,size')><!--- Declare --->
		
		<cfloop query="ARGUMENTS.qTheirSeasons">
			<cfset LOCAL.urlLibrary = LOCAL.pmsURL & ARGUMENTS.qTheirSeasons.seasonKey[ARGUMENTS.qTheirSeasons.currentRow] & '?' & LOCAL.pmsTokenStr>
			
			<cfhttp url="#LOCAL.urlLibrary#" method="GET" throwOnError="Yes" timeout="60"/>
		
			<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
			
			<!--- Parse Data Structure To Query Object --->
			<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
				<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XmlAttributes')>
					<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
						<cfset LOCAL.aEpisodes = LOCAL.xmlLibrary.MediaContainer.XMLChildren>
						
						<cfif IsArray(LOCAL.aEpisodes)>
							<cfloop array="#LOCAL.aEpisodes#" index="LOCAL.xmlEpisode">
								<cfset LOCAL.episodeNum = ''>
												
								<cfif StructKeyExists(LOCAL.xmlEpisode, 'XmlAttributes')>
									<cfif (LOCAL.xmlEpisode.XmlAttributes.title NEQ 'All episodes')>
										<cfif StructKeyExists(LOCAL.xmlEpisode.XmlAttributes, 'index')>
											<cfset LOCAL.episodeNum = LOCAL.xmlEpisode.XmlAttributes.index>
										</cfif>
										<cfif StructKeyExists(LOCAL.xmlEpisode.XmlAttributes, 'title')>
											<cfset LOCAL.episodeTitle = LOCAL.xmlEpisode.XmlAttributes.title>
										</cfif>
									</cfif>	
								</cfif>
								
								<cfif StructKeyExists(LOCAL.xmlEpisode, 'XMLChildren')>
									<cfset LOCAL.aMedia = LOCAL.xmlEpisode.XMLChildren>
														
									<cfif IsArray(LOCAL.aMedia)>
										<cfloop array="#LOCAL.aMedia#" index="LOCAL.xmlMedia">
											<cfif StructKeyExists(LOCAL.xmlMedia, 'XmlAttributes')>
												
												<cfif StructKeyExists(LOCAL.xmlMedia.XmlAttributes, 'videoResolution')>
													<cfset LOCAL.videoResolution = LOCAL.xmlMedia.XmlAttributes.videoResolution>
												</cfif>
												<cfif StructKeyExists(LOCAL.xmlMedia.XmlAttributes, 'index')>
													<cfset LOCAL.episodeNum = LOCAL.xmlMedia.XmlAttributes.index>
												</cfif>
											</cfif>
											
											<cfif StructKeyExists(LOCAL.xmlMedia, 'XmlChildren')>
												<cfset LOCAL.aParts = LOCAL.xmlMedia.XMLChildren>
									
												<cfif IsArray(LOCAL.aParts)>
													<cfloop array="#LOCAL.aParts#" index="LOCAL.xmlParts">
														
														
														<cfif StructKeyExists(LOCAL.xmlParts, 'XmlAttributes')
															AND StructKeyExists(LOCAL.xmlParts.XmlAttributes, 'key')>
															<cfset QueryAddRow(LOCAL.qTheirEpisodes)>
															
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'urlInfo', LOCAL.urlLibrary)>
															<cfset LOCAL.urlDownload = LOCAL.pmsURL & LOCAL.xmlParts.XmlAttributes.key & '?' & LOCAL.pmsTokenStr>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'urlDownload', LOCAL.urlDownload)>
											
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'libraryTitle', ARGUMENTS.libraryTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'showTitle', ARGUMENTS.qTheirSeasons.showTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'showKey', ARGUMENTS.qTheirSeasons.showKey)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'seasonTitle', ARGUMENTS.qTheirSeasons.seasonTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'seasonKey', ARGUMENTS.qTheirSeasons.seasonKey)>
															
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeNum', ((NOT IsNumeric(LOCAL.episodeNum)) ? 0 : LOCAL.episodeNum))>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeTitle', LOCAL.episodeTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'videoResolution', ((NOT IsNumeric(LOCAL.videoResolution)) ? 480 : LOCAL.videoResolution))>
																																									
															<cfif StructKeyExists(LOCAL.xmlParts.XmlAttributes, 'container')>
																<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'container', LOCAL.xmlParts.XmlAttributes.container)>
															</cfif>
															<cfif StructKeyExists(LOCAL.xmlParts.XmlAttributes, 'size')>
																<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'size', ((NOT IsNumeric(LOCAL.xmlParts.XmlAttributes.size)) ? 0 : LOCAL.xmlParts.XmlAttributes.size))>
															</cfif>												
															<cfif StructKeyExists(LOCAL.xmlParts.XmlAttributes, 'key')>
																<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeKey', LOCAL.xmlParts.XmlAttributes.key)>
															</cfif>
														</cfif>
													</cfloop>
												</cfif>
											</cfif>
										</cfloop>
									</cfif>
								</cfif>														
							</cfloop>
						</cfif>
					</cfif>
				</cfif>	
			</cfif>
		</cfloop>
	
		<cfreturn LOCAL.qTheirEpisodes>
	</cffunction>
	
	
	<cffunction name="DownloadEpisodes" access="public" returnType="void" output="true">
		<cfargument name="qDownloadShows" type="query">
		
		<cfloop query="ARGUMENTS.qDownloadShows">
			<cfset LOCAL.seasonNum = ReplaceNoCase(ARGUMENTS.qDownloadShows.seasonTitle, 'Season ', '')>
			<cfset LOCAL.seasonNum = 's' & ((IsNumeric(LOCAL.seasonNum) AND (LOCAL.seasonNum LT 10)) ? '0' & LOCAL.seasonNum : LOCAL.seasonNum)>
			
			<cfset LOCAL.episodeNum = 'e' & ((IsNumeric(ARGUMENTS.qDownloadShows.episodeNum) AND (ARGUMENTS.qDownloadShows.episodeNum LT 10)) ? '0' & ARGUMENTS.qDownloadShows.episodeNum : ARGUMENTS.qDownloadShows.episodeNum)>
			<cfset LOCAL.container = ((Len(Trim(ARGUMENTS.qDownloadShows.container)) LT 3) ? ListLast(ARGUMENTS.qDownloadShows.episodeKey, '.') : ARGUMENTS.qDownloadShows.container)>
			
			<cfset LOCAL.newFileName = Trim(ARGUMENTS.qDownloadShows.showTitle & ' - '
				& LOCAL.seasonNum & LOCAL.episodeNum & ' - ' 
				& ARGUMENTS.qDownloadShows.episodeTitle & '.' & LOCAL.container)>
				
			<!--- TODO: Replace Special Characters Not ALlowed In File Name --->
			<cfset LOCAL.newFileName = validFileName(LOCAL.newFileName)>
							
			<cfset LOCAL.savePath = VARIABLES.shows.dropPath & validFolderName(ARGUMENTS.qDownloadShows.showTitle)>
			
			<cfif NOT DirectoryExists(LOCAL.savePath)>
				<cfdirectory action="create" directory="#LOCAL.savePath#">
			</cfif>
			
			<!--- Get Any Previously Downloaded Episodes --->
			<cfdirectory name="LOCAL.qDropEpisodes" directory="#savePath#">

			<!--- Check If Current Episode Already Downloaded, If So Ensure Sizes Are The Same --->
			<cfquery name="LOCAL.qDropEpisodesMatch" dbtype="query">
				SELECT *
				FROM [LOCAL].qDropEpisodes
				WHERE UPPER(name) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#JavaCast('string', UCase(LOCAL.newFileName))#">
					AND [size] = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qDownloadShows.size#">
			</cfquery>

			<!--- Not A Qualifying Duplicate Found In Drop Folder --->
			<cfif (LOCAL.qDropEpisodesMatch.recordcount EQ 0)>
				<cfset LOCAL.attemptDL = True>
				<cfset LOCAL.iCnt = 0>
				
				<cfloop condition="LOCAL.attemptDL">
					<cfset LOCAL.iCnt = IncrementValue(LOCAL.iCnt)>
					
					<!--- Download Episode To Drop Folder --->
					<cfhttp method="GET"
						url="#ARGUMENTS.qDownloadShows.urlDownload#" 
						path="#LOCAL.savePath#" 
						file="#LOCAL.newFileName#" />
	
					<!--- Plex Server Seems To Only Feed 1 Stream At A Time To Session, Make Delay To Ensure Stream Recognized As Complete --->
					<cfset Sleep(2000)>
					
					<!--- Check If Downloaded Episode Complete --->
					<cfdirectory name="LOCAL.qDroppedEpisode" directory="#savePath#" type="file" filter="#LOCAL.newFileName#">
					
					<!--- Filter Results To Match Requested Episode Name/Size  --->
					<cfquery name="LOCAL.qDroppedEpisodeMatch" dbtype="query">
						SELECT *
						FROM [LOCAL].qDroppedEpisode
						WHERE UPPER(name) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#UCase(LOCAL.newFileName)#">
							AND [size] = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qDownloadShows.size#">
					</cfquery>
					
					<!--- The Downloaded Episode Complete (Sizes Match) --->					
					<cfif (LOCAL.qDroppedEpisodeMatch.recordcount GTE 1)>
						<cfset LOCAL.attemptDL = False>
					<!--- Max Download Attempts Reached --->
					<cfelseif (LOCAL.iCnt GTE VARIABLES.shows.maxDLAttempts)>
						<cffile action="append" file="#savePath#\IncompleteFiles.txt" output="#LOCAL.newFileName# Is An Incomplete Download">
						<!---
						<cfif (VARIABLES.shows.deleteIncompleteFiles) AND FileExists('#LOCAL.savePath#/#LOCAL.newFileName#')>
							<cffile action="delete" file="#LOCAL.savePath#/#LOCAL.newFileName#">						
						</cfif>
						--->
						
						<cfset LOCAL.attemptDL = False>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn>
	</cffunction>
		
	<cffunction name="DeleteShowLibraryData" access="public" returnType="void" output="true">
		<cfargument name="serverID" type="numeric" required="true">
		<cfargument name="libraryTitle" type="string" required="true" default="">
		
		<cfquery datasource="Plex" result="LOCAL.qResult">
			DELETE FROM Shows
			WHERE serverID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.serverID#">
				<cfif (Len(Trim(ARGUMENTS.libraryTitle)) GT 0)>
					AND libraryTitle = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.libraryTitle#" maxlength="255">
				</cfif>
		</cfquery>
		
		<cfreturn>
	</cffunction>
			
	
	<cffunction name="SaveShowLibraryData" access="public" returnType="void" output="true">
		<cfargument name="serverID" type="numeric">
		<cfargument name="qShowLibraryData" type="query">
		
		<cfloop query="ARGUMENTS.qShowLibraryData">
			<!--- Only Log SHows That Have Valid Downloads --->
			<cfif (Len(Trim(ARGUMENTS.qShowLibraryData.urlDownload)) GT 0)>
				<cftry>
					<!--- Log Each Library Movie Data To DB --->
					<cfquery datasource="Plex" result="LOCAL.qResult">
						INSERT INTO Shows 
						(
							[serverID],
							[urlInfo],
							[urlDownload],
							[libraryTitle],
							[showTitle],
							[showKey],
							[seasonTitle],
							[seasonKey],
							[episodeNum],
							[episodeTitle],
							[episodeKey],
							[videoResolution],
							[container],
							[size]
						)
						VALUES 
						(
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.serverID#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.urlInfo#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.urlDownload#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.libraryTitle#" maxlength="255">,							
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.showTitle#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.showKey#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.seasonTitle#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.seasonKey#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#ARGUMENTS.qShowLibraryData.episodeNum#" null="#(IsNumeric(ARGUMENTS.qShowLibraryData.episodeNum) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.episodeTitle#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.episodeKey#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qShowLibraryData.videoResolution#" null="#(IsNumeric(ARGUMENTS.qShowLibraryData.videoResolution) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qShowLibraryData.container#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#ARGUMENTS.qShowLibraryData.size#" null="#(IsNumeric(ARGUMENTS.qShowLibraryData.size) ? False : True)#">
						)
					</cfquery>
				
					<cfcatch type="database">
					    <cfdump var="#cfcatch#">
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		
		<cfreturn>
	</cffunction>
	
	
</cfcomponent>
