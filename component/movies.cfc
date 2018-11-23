<cfcomponent name="movies" extends="utility">
	
	<cffunction name="GetMovieLibrary" access="public" returnType="query" output="true">
		<cfargument name="qServer" type="query">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="libraryKey" type="string">
										
		<cfset LOCAL.pmsURL = 'http://' & ARGUMENTS.qServer.ip & ':' & ARGUMENTS.qServer.port>
		<cfset LOCAL.pmsTokenStr = 'X-Plex-Token=' & ARGUMENTS.qServer.token>
		<cfset LOCAL.urlLibrary = LOCAL.pmsURL & '/library/sections/' & ARGUMENTS.libraryKey & '/all?' & LOCAL.pmsTokenStr>

		<cfset LOCAL.qTheirMovies = QueryNew('libraryTitle,art,thumb,contentRating,title,studio,summary,year,videoResolution,key,fileName,duration,addedAt,optimizedForStreaming,
			container,size,duplicate,originallyAvailableAt,aspectRatio,audioChannels,audioCodec,bitrate,height,width,videoCodec,videoFrameRate,urlInfo,urlDownload,rating,genres',
			'VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,Integer,VarChar,VarChar,VarChar,Integer,BigInt,Integer,
			VarChar,BigInt,Bit,Date,Integer,Integer,VarChar,Integer,Integer,Integer,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar')><!--- Declare --->
		
		<cfhttp url="#LOCAL.urlLibrary#" method="GET" throwOnError="Yes" timeout="60" />
		
		<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
		
		<!--- Parse Data Structure To Query Object --->
		<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
			<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
				<cfset LOCAL.aVideos = LOCAL.xmlLibrary.MediaContainer.XMLChildren>
				
				<cfif IsArray(LOCAL.aVideos)>
					<cfloop array="#LOCAL.aVideos#" index="LOCAL.xmlMovie">
						<cfset LOCAL.addedAt = ''>
						<cfset LOCAL.art = ''>
						<cfset LOCAL.thumb = ''>
						<cfset LOCAL.summary = ''>
						<cfset LOCAL.studio = ''>
						<cfset LOCAL.originallyAvailableAt = ''>
						<cfset LOCAL.contentRating = ''>
						<cfset LOCAL.rating = ''>
						<cfset LOCAL.title = ''>
						<cfset LOCAL.year = ''>
												
						<cfif StructKeyExists(LOCAL.xmlMovie, 'XmlAttributes')>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'addedAt')>
								<cfset LOCAL.addedAt = LOCAL.xmlMovie.XmlAttributes.addedAt>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'art')>
								<cfset LOCAL.art = LOCAL.xmlMovie.XmlAttributes.art>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'thumb')>
								<cfset LOCAL.thumb = LOCAL.xmlMovie.XmlAttributes.thumb>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'summary')>
								<cfset LOCAL.summary = LOCAL.xmlMovie.XmlAttributes.summary>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'studio')>
								<cfset LOCAL.studio = LOCAL.xmlMovie.XmlAttributes.studio>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'originallyAvailableAt')>
								<cfset LOCAL.originallyAvailableAt = LOCAL.xmlMovie.XmlAttributes.originallyAvailableAt>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'contentRating')>
								<cfset LOCAL.contentRating = LOCAL.xmlMovie.XmlAttributes.contentRating>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'rating')>
								<cfset LOCAL.rating = LOCAL.xmlMovie.XmlAttributes.rating>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'title')>
								<cfset LOCAL.title = LOCAL.xmlMovie.XmlAttributes.title>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'year')>
								<cfset LOCAL.year = LOCAL.xmlMovie.XmlAttributes.year>
							</cfif>
						</cfif>	
											
						<cfif StructKeyExists(LOCAL.xmlMovie, 'XmlChildren')>
							<cfset LOCAL.genres = getGenres(
								movieDetails = LOCAL.xmlMovie.XmlChildren
							)>
									
							<cfloop array="#LOCAL.xmlMovie.XmlChildren#" index="LOCAL.details">
								<cfif StructKeyExists(LOCAL.details, 'XmlAttributes') 
									AND StructKeyExists(LOCAL.details, 'XmlName')
									AND (LOCAL.details.XmlName EQ 'Media')>
									<!--- Define/Set Iterated Defaults --->
									<cfset LOCAL.videoResolution = ''>
									<cfset LOCAL.aspectRatio = ''>
									<cfset LOCAL.audioChannels = ''>
									<cfset LOCAL.audioCodec = ''>
									<cfset LOCAL.bitrate = ''>
									<cfset LOCAL.height = ''>
									<cfset LOCAL.width = ''>
									<cfset LOCAL.videoFrameRate = ''>
									<cfset LOCAL.optimizedForStreaming = ''>
	
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'aspectRatio')>
										<cfset LOCAL.aspectRatio = LOCAL.details.XmlAttributes.aspectRatio>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'audioChannels')>
										<cfset LOCAL.audioChannels = LOCAL.details.XmlAttributes.audioChannels>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'audioCodec')>
										<cfset LOCAL.audioCodec = LOCAL.details.XmlAttributes.audioCodec>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'bitrate')>
										<cfset LOCAL.bitrate = LOCAL.details.XmlAttributes.bitrate>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'height')>
										<cfset LOCAL.height = LOCAL.details.XmlAttributes.height>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'width')>
										<cfset LOCAL.width = LOCAL.details.XmlAttributes.width>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'videoCodec')>
										<cfset LOCAL.videoFrameRate =  LOCAL.details.XmlAttributes.videoCodec>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'videoResolution')>
										<cfset LOCAL.videoResolution = LOCAL.details.XmlAttributes.videoResolution>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'optimizedForStreaming')>
										<cfset LOCAL.optimizedForStreaming = LOCAL.details.XmlAttributes.optimizedForStreaming>
									</cfif>
	
									<cfif StructKeyExists(LOCAL.details, 'XmlChildren')>
										<cfloop array="#LOCAL.details.XmlChildren#" index="LOCAL.parts">
											<cfset LOCAL.key = ''>
											<cfset LOCAL.fileName = ''>
											<cfset LOCAL.container = ''>
											<cfset LOCAL.size = ''>
											<cfset LOCAL.duration = ''>
													
											<cfif StructKeyExists(LOCAL.parts, 'XmlAttributes')>
												<cfif StructKeyExists(LOCAL.parts.XmlAttributes, 'key')>
													<cfset LOCAL.key = LOCAL.parts.XmlAttributes.key>
												</cfif>
												<cfif StructKeyExists(LOCAL.parts.XmlAttributes, 'file')>
													<cfset LOCAL.fileName = LOCAL.parts.XmlAttributes.file>
												</cfif>
												<cfif StructKeyExists(LOCAL.parts.XmlAttributes, 'container')>
													<cfset LOCAL.container = LOCAL.parts.XmlAttributes.container>
												</cfif>
												<cfif StructKeyExists(LOCAL.parts.XmlAttributes, 'size')>
													<cfset LOCAL.size = LOCAL.parts.XmlAttributes.size>
												</cfif>
												<cfif StructKeyExists(LOCAL.parts.XmlAttributes, 'duration')>
													<cfset LOCAL.duration = LOCAL.parts.XmlAttributes.duration>
												</cfif>
											</cfif>
											
											<cfset QueryAddRow(LOCAL.qTheirMovies)>
											
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'urlInfo', LOCAL.urlLibrary)>
											<cfset LOCAL.urlDownload = LOCAL.pmsURL & LOCAL.key & '?' & LOCAL.pmsTokenStr>
											<!---
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'urlDownload', ((urlExists(LOCAL.urlDownload)) ? LOCAL.urlDownload : ''))>
											--->
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'urlDownload', LOCAL.urlDownload)>
											
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'libraryTitle', ARGUMENTS.libraryTitle)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'addedAt', (IsNumeric(LOCAL.addedAt) ? LOCAL.addedAt : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'art', LOCAL.art)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'thumb', LOCAL.thumb)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'summary', LOCAL.summary)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'studio', LOCAL.studio)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'originallyAvailableAt', (IsDate(LOCAL.originallyAvailableAt) ? LOCAL.originallyAvailableAt : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'contentRating', LOCAL.contentRating)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'rating', (IsNumeric(LOCAL.rating) ? LOCAL.rating : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'genres', LOCAL.genres)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'title', LOCAL.title)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'year', (IsNumeric(LOCAL.year) ? LOCAL.year : JavaCast('null', '')))>
											
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'videoResolution', (IsNumeric(LOCAL.videoResolution) ? LOCAL.videoResolution : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'aspectRatio', LOCAL.aspectRatio)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'audioChannels', (IsNumeric(LOCAL.audioChannels) ? LOCAL.audioChannels : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'audioCodec', LOCAL.audioCodec)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'bitrate', (IsNumeric(LOCAL.bitrate) ? LOCAL.bitrate : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'height', (IsNumeric(LOCAL.height) ? LOCAL.height : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'width', (IsNumeric(LOCAL.width) ? LOCAL.width : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'videoFrameRate', LOCAL.videoFrameRate)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'videoFrameRate', LOCAL.videoFrameRate)>
											
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'key', LOCAL.key)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'fileName', LOCAL.fileName)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'container', LOCAL.container)>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'size', (IsNumeric(LOCAL.size) ? LOCAL.size : JavaCast('null', '')))>
											<cfset QuerySetCell(LOCAL.qTheirMovies, 'optimizedForStreaming', (IsNumeric(LOCAL.optimizedForStreaming) ? LOCAL.optimizedForStreaming : JavaCast('null', '')))>
										</cfloop>										
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>			
				
			</cfif>	
		</cfif>
	
		<cfreturn LOCAL.qTheirMovies>
	</cffunction>
	
	<cffunction name="GetGenres" access="public" returnType="string" output="true">
		<cfargument name="movieDetails" type="array" required="true">
		
		<cfset LOCAL.genres = ''>
		
		<cfloop array="#ARGUMENTS.movieDetails#" index="LOCAL.element">
			<cfif StructKeyExists(LOCAL.element, 'XmlName') AND (LOCAL.element.XmlName EQ 'Genre')>
				<cfif StructKeyExists(LOCAL.element, 'XmlAttributes')>
					<cfif StructKeyExists(LOCAL.element.XmlAttributes, 'tag')>
						<cfset LOCAL.genres = ListAppend(LOCAL.genres, LOCAL.element.XmlAttributes.tag)>
					</cfif>
				</cfif>			
			</cfif>
		</cfloop>
		
		<cfreturn LOCAL.genres>
	</cffunction>
		
		
	<cffunction name="DeleteMovieLibraryData" access="public" returnType="void" output="true">
		<cfargument name="serverID" type="numeric" required="true">
		<cfargument name="libraryTitle" type="string" required="true" default="">
		
		<cfquery datasource="Plex" result="LOCAL.qResult">
			DELETE FROM Movies
			WHERE serverID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.serverID#">
				<cfif (Len(Trim(ARGUMENTS.libraryTitle)) GT 0)>
					AND libraryTitle = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.libraryTitle#" maxlength="255">
				</cfif>
		</cfquery>
		
		<cfreturn>
	</cffunction>
			
	
	<cffunction name="SaveMovieLibraryData" access="public" returnType="void" output="true">
		<cfargument name="serverID" type="numeric">
		<cfargument name="qMovieLibraryData" type="query">
		
		<cfloop query="ARGUMENTS.qMovieLibraryData">
			<!--- Only Log Movies That Have Valid Downloads --->
			<cfif (Len(Trim(ARGUMENTS.qMovieLibraryData.urlDownload)) GT 0)>
				<cftry>
					<!--- Log Each Library Movie Data To DB --->
					<cfquery datasource="Plex" result="LOCAL.qResult">
						INSERT INTO Movies 
						(
							[serverID],
							[key],
							[urlInfo],
							[urlDownload],
							[libraryTitle],
							[addedAt],
							[art],
							[thumb],
							[title],
							[year],
							[originallyAvailableAt],
							[contentRating],
							[rating],
							[genres],
							[summary],
							[duration],
							[container],
							[videoResolution],
							[optimizedForStreaming],
							[size],
							[aspectRatio],
							[audioChannels],
							[audioCodec],
							[bitrate],
							[height],
							[width],
							[videoFrameRate],
							[fileName]
						)
						VALUES 
						(
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.serverID#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.key#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.urlInfo#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.urlDownload#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.libraryTitle#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#ARGUMENTS.qMovieLibraryData.addedAt#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.addedAt) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.art#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.thumb#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.title#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#ARGUMENTS.qMovieLibraryData.year#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.year) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_DATE" value="#ARGUMENTS.qMovieLibraryData.originallyAvailableAt#" null="#(IsDate(ARGUMENTS.qMovieLibraryData.originallyAvailableAt) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.contentRating#" maxlength="10">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.rating#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.rating) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.genres#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.summary#">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qMovieLibraryData.duration#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.duration) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.container#" maxlength="50">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qMovieLibraryData.videoResolution#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.videoResolution) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qMovieLibraryData.optimizedForStreaming#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.optimizedForStreaming) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#ARGUMENTS.qMovieLibraryData.size#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.size) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.aspectRatio#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#ARGUMENTS.qMovieLibraryData.audioChannels#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.audioChannels) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.audioCodec#" maxlength="255">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qMovieLibraryData.bitrate#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.bitrate) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qMovieLibraryData.height#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.height) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ARGUMENTS.qMovieLibraryData.width#" null="#(IsNumeric(ARGUMENTS.qMovieLibraryData.width) ? False : True)#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.videoFrameRate#" maxlength="50">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ARGUMENTS.qMovieLibraryData.fileName#">
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
		
	<cffunction name="FlagDuplicateMovies" access="public" returnType="query" output="true">
		<cfargument name="qMyMovies" type="query">
		<cfargument name="qDropMovies" type="query">
		<cfargument name="qTheirMovies" type="query">					
		
		<cfset LOCAL.qTheirMovies = Duplicate(ARGUMENTS.qTheirMovies)>
		
		<cfloop query="LOCAL.qTheirMovies">
			<cfset LOCAL.newFileName = LOCAL.qTheirMovies.title[LOCAL.qTheirMovies.currentRow] & ' (' & LOCAL.qTheirMovies.year[LOCAL.qTheirMovies.currentRow] & ').' & LOCAL.qTheirMovies.container[LOCAL.qTheirMovies.currentRow]>
			<cfset LOCAL.size = LOCAL.qTheirMovies.size[LOCAL.qTheirMovies.currentRow]>
			
			<cfquery name="LOCAL.qMyMoviesMatch" dbtype="query">
				SELECT *
				FROM ARGUMENTS.qMyMovies
				WHERE UPPER(name) LIKE <cfqueryparam value="#UCase(ReplaceNoCase(ReplaceNoCase(Reverse(ReplaceNoCase(Reverse(LOCAL.newFileName), ListFirst(Reverse(LOCAL.newFileName), '.'), '')), ' :', ' -', 'ALL'), ':', ' -', 'ALL'))#%" CFSQLType="CF_SQL_VARCHAR">
					<cfif IsDefined('LOCAL.size') AND IsNumeric(LOCAL.size)>
					AND ((size >= #LOCAL.size#) OR (((size < #LOCAL.size#) AND size >= 1))) <!--- 1468006400 Don't Replace Any Existing Movies Over 1.4 GB --->
					</cfif>
			</cfquery>
			
			<!--- Not A Qualifying Duplicate From My Library --->
			<cfif (LOCAL.qMyMoviesMatch.recordcount EQ 0)>
				<cfquery name="LOCAL.qDropMoviesMatch" dbtype="query">
					SELECT *
					FROM ARGUMENTS.qDropMovies
					WHERE UPPER(name) LIKE <cfqueryparam value="#UCase(ReplaceNoCase(ReplaceNoCase(Reverse(ReplaceNoCase(Reverse(LOCAL.newFileName), ListFirst(Reverse(LOCAL.newFileName), '.'), '')), ' :', ' -', 'ALL'), ':', ' -', 'ALL'))#%" CFSQLType="CF_SQL_VARCHAR">
				</cfquery>
				
				<!--- Not A Qualifying Duplicate From What Is In Downloads --->
				<cfif (LOCAL.qDropMoviesMatch.recordcount GT 0) AND IsDefined('LOCAL.size') AND IsNumeric(LOCAL.size)>
					<cfquery name="LOCAL.qDropMoviesMatch" dbtype="query">
						SELECT *
						FROM [LOCAL].qDropMoviesMatch
						WHERE size = #LOCAL.size#
					</cfquery>
				</cfif>
				
				<!--- Not A Qualifying Duplicate From What Is In Downloads --->
				<cfset QuerySetCell(LOCAL.qTheirMovies, 'duplicate', ((LOCAL.qDropMoviesMatch.recordcount EQ 0) ? 0 : 1), LOCAL.qTheirMovies.currentRow)>
			<cfelse>
				<cfset QuerySetCell(LOCAL.qTheirMovies, 'duplicate', 1, LOCAL.qTheirMovies.currentRow)>
			</cfif>
		</cfloop>
		
		<cfreturn LOCAL.qTheirMovies>
	</cffunction>
	
	<cffunction name="DownloadMovies" access="public" returnType="void" output="true">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		<cfargument name="qTheirMovies" type="query">					
		<cfargument name="movieDropPath" type="string">
		
		<cfset LOCAL.manualDL = True>
		
		<cfset LOCAL.qTheirMovies = Duplicate(ARGUMENTS.qTheirMovies)>

		<cfloop query="LOCAL.qTheirMovies">
			<cfset LOCAL.newFileName = LOCAL.qTheirMovies.title & ' (' & LOCAL.qTheirMovies.year & ').' & LOCAL.qTheirMovies.container>
			
			<cfif LOCAL.manualDL>
				<cfoutput>
				
				<input type="button" name="copyFileName" value="Copy" onClick="copyFileName('#title# (#year#).#container#');"> 
				<a href="#LOCAL.pmsURL##LOCAL.qTheirMovies.key#?#LOCAL.pmsTokenStr#">#title# (#year#) </a>[#videoResolution#] - #NumberFormat(size / 1024 / 1024)# MB | 
				&nbsp;[<a href="https://www.imdb.com/find?ref_=nv_sr_fn&q=#URLEncodedFormat(title & '(' & year & ')')#&s=all" target="_blank">IMDB</a>]<br></cfoutput>
			<cfelse>
				<cfhttp method="GET"
					url="#LOCAL.pmsURL##LOCAL.qTheirMovies.key#?#LOCAL.pmsTokenStr#" 
					path="#ARGUMENTS.movieDropPath#" 
					file="#LOCAL.newFileName#" />
					
				<cfset Sleep(2000)>
			</cfif>
		</cfloop>
		
		<cfreturn>
	</cffunction>
	
	
</cfcomponent>
