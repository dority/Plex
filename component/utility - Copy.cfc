<cfcomponent name="utility">
	
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
	
	<cffunction name="GetPhotos" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="url" type="string">
				
		<cfset LOCAL.collectionTitle = ''>
		
		<cfset LOCAL.qTheirPhotos = QueryNew('libraryTitle,collectionTitle,photoTitle,photoKey,photoContainer')><!--- Declare --->
		
		<cfhttp url="#ARGUMENTS.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
		<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
		
		<!--- Parse Data Structure To Query Object --->
		<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>		
			<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
				<cfset LOCAL.aCollections = LOCAL.xmlLibrary.MediaContainer.XMLChildren>

				<cfif IsArray(LOCAL.aCollections)>
					<cfloop array="#LOCAL.aCollections#" index="LOCAL.xmlCollection">
						
						
						<cfset LOCAL.photoTitle = ''>
						<cfset LOCAL.photoKey = ''>
						
										
						<cfif StructKeyExists(LOCAL.xmlCollection, 'XmlName')>
							<cfif (LOCAL.xmlCollection.XmlName EQ 'Directory')>
								<cfif StructKeyExists(LOCAL.xmlCollection, 'XmlAttributes')>
									<cfif StructKeyExists(LOCAL.xmlCollection, 'XmlAttributes')>
										<cfif StructKeyExists(LOCAL.xmlCollection.XmlAttributes, 'title')>
											<cfset LOCAL.collectionTitle = LOCAL.xmlCollection.XmlAttributes.title>
										</cfif>
									</cfif>
								</cfif>
							<cfelseif (ListFindNoCase('Photo,Video', LOCAL.xmlCollection.XmlName) NEQ 0)>
								<cfif StructKeyExists(LOCAL.xmlCollection, 'XmlAttributes')>
												
									<cfif StructKeyExists(LOCAL.xmlCollection.XmlAttributes, 'title')>
										<cfset LOCAL.photoTitle = LOCAL.xmlCollection.XmlAttributes.title>
									</cfif>
									<cfif StructKeyExists(LOCAL.xmlCollection.XmlAttributes, 'thumb')>
										<cfset LOCAL.photoKey = LOCAL.xmlCollection.XmlAttributes.thumb>
									</cfif>
									
									<cfif StructKeyExists(LOCAL.xmlCollection, 'XMLChildren')>
										<cfset LOCAL.aMedia = LOCAL.xmlCollection.XMLChildren>
									
										<cfloop array="#LOCAL.aMedia#" index="LOCAL.xmlMedia">
											<cfif StructKeyExists(LOCAL.xmlMedia, 'XMLChildren')>
												<cfset LOCAL.aParts = LOCAL.xmlMedia.XMLChildren>
												
												<cfloop array="#LOCAL.aParts#" index="LOCAL.xmlPart">
													<cfif StructKeyExists(LOCAL.xmlPart, 'XmlAttributes')>
														<cfset QueryAddRow(LOCAL.qTheirPhotos)>
									
														<cfset QuerySetCell(LOCAL.qTheirPhotos, 'libraryTitle', ARGUMENTS.libraryTitle)>
														<cfset QuerySetCell(LOCAL.qTheirPhotos, 'collectionTitle', LOCAL.collectionTitle)>
														<cfset QuerySetCell(LOCAL.qTheirPhotos, 'photoTitle', LOCAL.photoTitle)>
														<cfset QuerySetCell(LOCAL.qTheirPhotos, 'photoKey', LOCAL.photoKey)>
														
														<cfif StructKeyExists(LOCAL.xmlPart.XmlAttributes, 'container')>
															<cfset QuerySetCell(LOCAL.qTheirPhotos, 'photoContainer', LOCAL.xmlPart.XmlAttributes.container)>
														</cfif>
													</cfif>														
												</cfloop>
											</cfif>
										</cfloop>
									</cfif>
								</cfif>
							</cfif>
							
						</cfif>
					</cfloop>
				</cfif>
			</cfif>	
		</cfif>
														
		<cfreturn LOCAL.qTheirPhotos>
	</cffunction>
	
	<cffunction name="GetShows" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="url" type="string">
				
		
		<cfset LOCAL.qTheirShows = QueryNew('libraryTitle,showTitle,showkey')><!--- Declare --->
		
		<cfhttp url="#ARGUMENTS.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
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
	
	<cffunction name="GetArtists" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="url" type="string">
				
		
		<cfset LOCAL.qTheirArtists = QueryNew('libraryTitle,artistTitle,artistKey')><!--- Declare --->
		
		<cfhttp url="#ARGUMENTS.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
		<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
		
		<!--- Parse Data Structure To Query Object --->
		<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
			<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
				<cfset LOCAL.aArtists = LOCAL.xmlLibrary.MediaContainer.XMLChildren>

				<cfif IsArray(LOCAL.aArtists)>
					<cfloop array="#LOCAL.aArtists#" index="LOCAL.xmlAtrist">
								
						<cfif StructKeyExists(LOCAL.xmlAtrist, 'XmlAttributes')>
							<cfif StructKeyExists(LOCAL.xmlAtrist.XmlAttributes, 'title')>
								<cfset LOCAL.artistTitle = LOCAL.xmlAtrist.XmlAttributes.title>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlAtrist.XmlAttributes, 'key')>
								<cfset LOCAL.artistKey = LOCAL.xmlAtrist.XmlAttributes.key>
							</cfif>
						</cfif>
						
						<cfset QueryAddRow(LOCAL.qTheirArtists)>
										
						<cfset QuerySetCell(LOCAL.qTheirArtists, 'libraryTitle', ARGUMENTS.libraryTitle)>
						<cfset QuerySetCell(LOCAL.qTheirArtists, 'artistTitle', validFolderName(LOCAL.artistTitle))>
						<cfset QuerySetCell(LOCAL.qTheirArtists, 'artistKey', LOCAL.artistKey)>
					</cfloop>
					
					
				</cfif>			
				
			</cfif>	
		</cfif>
	
		<cfreturn LOCAL.qTheirArtists>
	</cffunction>
	
	<cffunction name="GetAlbums" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="qTheirArtists" type="query">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		
				
		<cfset LOCAL.qTheirAlbums = QueryNew('libraryTitle,artistTitle,artistKey,albumTitle,albumKey,albumYear,albumArt,duplicate')><!--- Declare --->
		
		<cfloop query="ARGUMENTS.qTheirArtists">
			<cfset LOCAL.url = ARGUMENTS.pmsURL & ARGUMENTS.qTheirArtists.artistKey[ARGUMENTS.qTheirArtists.currentRow] & '?' & ARGUMENTS.pmsTokenStr>
			
			<cfhttp url="#LOCAL.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
			<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
			
			<!--- Parse Data Structure To Query Object --->
			<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
				<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XmlAttributes')>
					<cfset LOCAL.aAlbums = LOCAL.xmlLibrary.MediaContainer.XMLChildren>
					
					<cfif IsArray(LOCAL.aAlbums)>
						<cfloop array="#LOCAL.aAlbums#" index="LOCAL.xmlAlbum">
							
							<cfif StructKeyExists(LOCAL.xmlAlbum, 'XmlAttributes')>
								<cfif (LOCAL.xmlAlbum.XmlAttributes.type EQ 'album')>
									<cfset QueryAddRow(LOCAL.qTheirAlbums)>
									
									<cfset QuerySetCell(LOCAL.qTheirAlbums, 'libraryTitle', ARGUMENTS.libraryTitle)>
									<cfset QuerySetCell(LOCAL.qTheirAlbums, 'artistTitle', ARGUMENTS.qTheirArtists.artistTitle)>
									<cfset QuerySetCell(LOCAL.qTheirAlbums, 'artistKey', ARGUMENTS.qTheirArtists.artistKey)>
									
									<cfif StructKeyExists(LOCAL.xmlAlbum.XmlAttributes, 'year')>
										<cfset QuerySetCell(LOCAL.qTheirAlbums, 'albumYear', (IsNumeric(LOCAL.xmlAlbum.XmlAttributes.year) ? LOCAL.xmlAlbum.XmlAttributes.year : 0))>
									</cfif>
									<cfif StructKeyExists(LOCAL.xmlAlbum.XmlAttributes, 'thumb')>
										<cfset QuerySetCell(LOCAL.qTheirAlbums, 'albumArt', LOCAL.xmlAlbum.XmlAttributes.thumb)>
									</cfif>
									<cfif StructKeyExists(LOCAL.xmlAlbum.XmlAttributes, 'title')>
										<cfset QuerySetCell(LOCAL.qTheirAlbums, 'albumTitle', LOCAL.xmlAlbum.XmlAttributes.title)>
									</cfif>
									<cfif StructKeyExists(LOCAL.xmlAlbum.XmlAttributes, 'key')>
										<cfset QuerySetCell(LOCAL.qTheirAlbums, 'albumKey', LOCAL.xmlAlbum.XmlAttributes.key)>
									</cfif>
								</cfif>	
							</cfif>							
						</cfloop>
					</cfif>
				</cfif>	
			</cfif>
		</cfloop>
	
		<cfreturn LOCAL.qTheirAlbums>
	</cffunction>
	
	<cffunction name="GetTracks" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="qTheirAlbums" type="query">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">

		<cfset LOCAL.qTheirTracks = QueryNew('libraryTitle,artistTitle,artistKey,albumTitle,albumKey,albumYear,albumArt,duplicate,trackNum,trackTitle,trackKey,trackBitRate,trackContainer,trackSize')><!--- Declare --->
		
		<cfloop query="ARGUMENTS.qTheirAlbums">
			<cfset LOCAL.url = ARGUMENTS.pmsURL & ARGUMENTS.qTheirAlbums.albumKey & '?' & ARGUMENTS.pmsTokenStr>
			
			<cfhttp url="#LOCAL.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
			<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
			
			<!--- Parse Data Structure To Query Object --->
			<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
				<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XmlAttributes')>
					<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
						<cfset LOCAL.aTracks = LOCAL.xmlLibrary.MediaContainer.XMLChildren>
						
						<cfif IsArray(LOCAL.aTracks)>							
							<cfloop array="#LOCAL.aTracks#" index="LOCAL.xmlTrack">
			
								<cfif StructKeyExists(LOCAL.xmlTrack, 'XmlChildren')>
									<cfset LOCAL.aMedias = LOCAL.xmlTrack.XMLChildren>
										
									<cfset LOCAL.trackNum = ''>
									<cfset LOCAL.trackTitle = ''>
									
									<cfif StructKeyExists(LOCAL.xmlTrack, 'XmlAttributes')>
										<cfif StructKeyExists(LOCAL.xmlTrack.XmlAttributes, 'index')>
											<cfset LOCAL.trackNum = LOCAL.xmlTrack.XmlAttributes.index>
										</cfif>
										<cfif StructKeyExists(LOCAL.xmlTrack.XmlAttributes, 'title')>
											<cfset LOCAL.trackTitle = LOCAL.xmlTrack.XmlAttributes.title>
										</cfif>
									</cfif>
														
									<cfif IsArray(LOCAL.aMedias)>
										<cfloop array="#LOCAL.aMedias#" index="LOCAL.xmlMedia">
											<cfset LOCAL.trackBitRate = ''>
											
											<cfif StructKeyExists(LOCAL.xmlMedia, 'XmlAttributes')>
												<cfif StructKeyExists(LOCAL.xmlMedia.XmlAttributes, 'bitrate')>
													<cfset LOCAL.trackBitRate = LOCAL.xmlMedia.XmlAttributes.bitrate>
												</cfif>
											</cfif>

											<cfif StructKeyExists(LOCAL.xmlMedia, 'XmlChildren')>
												<cfset LOCAL.aParts = LOCAL.xmlMedia.XMLChildren>
																								
												<cfif IsArray(LOCAL.aParts)>
													<cfloop array="#LOCAL.aParts#" index="LOCAL.xmlPart">
														<cfif StructKeyExists(LOCAL.xmlPart, 'XmlAttributes')>
															<cfset QueryAddRow(LOCAL.qTheirTracks)>
										
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'libraryTitle', ARGUMENTS.libraryTitle)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'artistTitle', ARGUMENTS.qTheirAlbums.artistTitle)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'artistKey', ARGUMENTS.qTheirAlbums.artistKey)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'albumTitle', ARGUMENTS.qTheirAlbums.albumTitle)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'albumKey', ARGUMENTS.qTheirAlbums.albumKey)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'albumYear', ARGUMENTS.qTheirAlbums.albumYear)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'albumArt', ARGUMENTS.qTheirAlbums.albumArt)>

															<cfset QuerySetCell(LOCAL.qTheirTracks, 'trackNum', (IsNumeric(LOCAL.trackNum) ? LOCAL.trackNum : 0))>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'trackTitle', LOCAL.trackTitle)>
															<cfset QuerySetCell(LOCAL.qTheirTracks, 'trackBitRate', (IsNumeric(LOCAL.trackBitRate) ? LOCAL.trackBitRate : 0))>
															
															<cfif StructKeyExists(LOCAL.xmlPart.XmlAttributes, 'key')>
																<cfset QuerySetCell(LOCAL.qTheirTracks, 'trackKey', LOCAL.xmlPart.XmlAttributes.key)>
															</cfif>
															<cfif StructKeyExists(LOCAL.xmlPart.XmlAttributes, 'container')>
																<cfset QuerySetCell(LOCAL.qTheirTracks, 'trackContainer', LOCAL.xmlPart.XmlAttributes.container)>
															</cfif>
															<cfif StructKeyExists(LOCAL.xmlPart.XmlAttributes, 'size')>
																<cfset QuerySetCell(LOCAL.qTheirTracks, 'trackSize', (IsNumeric(LOCAL.xmlPart.XmlAttributes.size) ? LOCAL.xmlPart.XmlAttributes.size : 0))>
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
	
		<cfreturn LOCAL.qTheirTracks>
	</cffunction>
	
	<cffunction name="FlagDuplicateAlbums" access="public" returnType="query" output="true">
		<cfargument name="qMyAlbums" type="query">
		<cfargument name="qTheirAlbums" type="query">					
		
		<cfset LOCAL.qTheirAlbums = Duplicate(ARGUMENTS.qTheirAlbums)>
		
		<cfloop query="LOCAL.qTheirAlbums">
			<cfset LOCAL.artistTitle = LOCAL.qTheirAlbums.artistTitle> 
			<cfset LOCAL.albumTitle = LOCAL.qTheirAlbums.albumTitle>
			
			<cfquery name="LOCAL.qMyAlbumsMatch" dbtype="query">
				SELECT *
				FROM ARGUMENTS.qMyAlbums
				WHERE UPPER(directory) LIKE <cfqueryparam value="%\#UCase(validFolderName(LOCAL.artistTitle))#" CFSQLType="CF_SQL_VARCHAR">
					AND UPPER(name) = <cfqueryparam value="#UCase(validFolderName(LOCAL.albumTitle))#" CFSQLType="CF_SQL_VARCHAR">
			</cfquery>

			<!--- Not A Qualifying Duplicate From What Is In Downloads --->
			<cfset QuerySetCell(LOCAL.qTheirAlbums, 'duplicate', ((LOCAL.qMyAlbumsMatch.recordcount EQ 0) ? 0 : 1), LOCAL.qTheirAlbums.currentRow)>
		</cfloop>
		
		<cfreturn LOCAL.qTheirAlbums>
	</cffunction>
	
	<cffunction name="GetSeasons" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="qTheirShows" type="query">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		
				
		<cfset LOCAL.qTheirSeasons = QueryNew('libraryTitle,showTitle,showKey,seasonTitle,seasonKey')><!--- Declare --->
		
		<cfloop query="ARGUMENTS.qTheirShows">
			<cfset LOCAL.url = ARGUMENTS.pmsURL & ARGUMENTS.qTheirShows.showKey[ARGUMENTS.qTheirShows.currentRow] & '?' & ARGUMENTS.pmsTokenStr>
			
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
		<cfargument name="libraryTitle" type="string">
		<cfargument name="qTheirSeasons" type="query">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		
				
		<cfset LOCAL.qTheirEpisodes = QueryNew('libraryTitle,showTitle,showKey,seasonTitle,seasonKey,episodeNum,episodeTitle,episodeKey,episodeVideoResolution,episodeContainer,episodeSize')><!--- Declare --->
		
		<cfloop query="ARGUMENTS.qTheirSeasons">
			<cfset LOCAL.url = ARGUMENTS.pmsURL & ARGUMENTS.qTheirSeasons.seasonKey[ARGUMENTS.qTheirSeasons.currentRow] & '?' & ARGUMENTS.pmsTokenStr>
			
			<cfhttp url="#LOCAL.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
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
													<cfset LOCAL.episodeVideoResolution = LOCAL.xmlMedia.XmlAttributes.videoResolution>
												</cfif>
												<cfif StructKeyExists(LOCAL.xmlMedia.XmlAttributes, 'index')>
													<cfset LOCAL.episodeNum = LOCAL.xmlMedia.XmlAttributes.index>
												</cfif>
											</cfif>
											
											<cfif StructKeyExists(LOCAL.xmlMedia, 'XmlChildren')>
												<cfset LOCAL.aParts = LOCAL.xmlMedia.XMLChildren>
									
												<cfif IsArray(LOCAL.aParts)>
													<cfloop array="#LOCAL.aParts#" index="LOCAL.xmlParts">
														
														
														<cfif StructKeyExists(LOCAL.xmlParts, 'XmlAttributes')>
															<cfset QueryAddRow(LOCAL.qTheirEpisodes)>
											
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'libraryTitle', ARGUMENTS.libraryTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'showTitle', ARGUMENTS.qTheirSeasons.showTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'showKey', ARGUMENTS.qTheirSeasons.showKey)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'seasonTitle', ARGUMENTS.qTheirSeasons.seasonTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'seasonKey', ARGUMENTS.qTheirSeasons.seasonKey)>
															
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeNum', ((NOT IsNumeric(LOCAL.episodeNum)) ? 0 : LOCAL.episodeNum))>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeTitle', LOCAL.episodeTitle)>
															<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeVideoResolution', ((NOT IsNumeric(LOCAL.episodeVideoResolution)) ? 480 : LOCAL.episodeVideoResolution))>
																																									
															<cfif StructKeyExists(LOCAL.xmlParts.XmlAttributes, 'container')>
																<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeContainer', LOCAL.xmlParts.XmlAttributes.container)>
															</cfif>
															<cfif StructKeyExists(LOCAL.xmlParts.XmlAttributes, 'size')>
																<cfset QuerySetCell(LOCAL.qTheirEpisodes, 'episodeSize', ((NOT IsNumeric(LOCAL.xmlParts.XmlAttributes.size)) ? 0 : LOCAL.xmlParts.XmlAttributes.size))>
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
	
	<cffunction name="GetMovieLibrary" access="public" returnType="query" output="true">
		<cfargument name="libraryTitle" type="string">
		<cfargument name="url" type="string">
				
		
		<cfset LOCAL.qTheirMovies = QueryNew('libraryTitle,art,thumb,contentRating,title,studio,summary,year,videoResolution,key,fileName,
			container,size,duplicate,originallyAvailableAt,aspectRatio,audioChannels,audioCodec,bitrate,height,width,videoCodec',
			'VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,Integer,VarChar,VarChar,VarChar,
			VarChar,BigInt,Bit,Date,Integer,Integer,VarChar,Integer,Integer,Integer,VarChar')><!--- Declare --->
		
		<cfhttp url="#ARGUMENTS.url#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>
		
		<cfset LOCAL.xmlLibrary = XmlParse(Trim(CFHTTP.FileContent))>
		
		<!--- Parse Data Structure To Query Object --->
		<cfif StructKeyExists(LOCAL.xmlLibrary, 'MediaContainer')>
			<cfif StructKeyExists(LOCAL.xmlLibrary.MediaContainer, 'XMLChildren')>
				<cfset LOCAL.aVideos = LOCAL.xmlLibrary.MediaContainer.XMLChildren>
				
				<cfif IsArray(LOCAL.aVideos)>
					<cfloop array="#LOCAL.aVideos#" index="LOCAL.xmlMovie">						
						<cfif StructKeyExists(LOCAL.xmlMovie, 'XmlAttributes')>
							<cfset LOCAL.art = JavaCast('null', '')>
							<cfset LOCAL.thumb = JavaCast('null', '')>
							<cfset LOCAL.summary = JavaCast('null', '')>
							<cfset LOCAL.studio = JavaCast('null', '')>
							<cfset LOCAL.originallyAvailableAt = JavaCast('null', '')>
							<cfset LOCAL.contentRating = JavaCast('null', '')>
							<cfset LOCAL.title = JavaCast('null', '')>
							<cfset LOCAL.year = JavaCast('null', '')>
							
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
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'title')>
								<cfset LOCAL.title = LOCAL.xmlMovie.XmlAttributes.title>
							</cfif>
							<cfif StructKeyExists(LOCAL.xmlMovie.XmlAttributes, 'year')>
								<cfset LOCAL.year = LOCAL.xmlMovie.XmlAttributes.year>
							</cfif>
						</cfif>
						
						<cfif StructKeyExists(LOCAL.xmlMovie, 'XmlChildren')>
							<cfloop array="#LOCAL.xmlMovie.XmlChildren#" index="LOCAL.details">
								<cfset LOCAL.videoResolution = JavaCast('null', '')>
								<cfset LOCAL.aspectRatio = JavaCast('null', '')>
								<cfset LOCAL.audioChannels = JavaCast('null', '')>
								<cfset LOCAL.audioCodec = JavaCast('null', '')>
								<cfset LOCAL.bitrate = JavaCast('null', '')>
								<cfset LOCAL.height = JavaCast('null', '')>
								<cfset LOCAL.width = JavaCast('null', '')>
								<cfset LOCAL.videoFrameRate =  JavaCast('null', '')>
								
								<cfif StructKeyExists(LOCAL.details, 'XmlAttributes')>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'aspectRatio')>
										<cfset LOCAL.aspectRatio = (IsNumeric(LOCAL.details.XmlAttributes.aspectRatio) ? LOCAL.details.XmlAttributes.aspectRatio : JavaCast('null', ''))>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'audioChannels')>
										<cfset LOCAL.audioChannels = (IsNumeric(LOCAL.details.XmlAttributes.audioChannels) ? LOCAL.details.XmlAttributes.audioChannels : JavaCast('null', ''))>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'audioCodec')>
										<cfset LOCAL.audioCodec = LOCAL.details.XmlAttributes.audioCodec>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'bitrate')>
										<cfset LOCAL.bitrate = (IsNumeric(LOCAL.details.XmlAttributes.bitrate) ? LOCAL.details.XmlAttributes.bitrate : JavaCast('null', ''))>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'height')>
										<cfset LOCAL.height = (IsNumeric(LOCAL.details.XmlAttributes.height) ? LOCAL.details.XmlAttributes.height : JavaCast('null', ''))>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'width')>
										<cfset LOCAL.width = (IsNumeric(LOCAL.details.XmlAttributes.width) ? LOCAL.details.XmlAttributes.width : JavaCast('null', ''))>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'videoCodec')>
										<cfset LOCAL.videoFrameRate =  LOCAL.details.XmlAttributes.videoCodec>
									</cfif>
									<cfif StructKeyExists(LOCAL.details.XmlAttributes, 'videoResolution')>
										<cfset LOCAL.videoResolution = (IsNumeric(LOCAL.details.XmlAttributes.audioChannels) ? LOCAL.details.XmlAttributes.audioChannels : 480)>
									</cfif>
								</cfif>

								<cfif StructKeyExists(LOCAL.details, 'XmlChildren')>
									<cfloop array="#LOCAL.details.XmlChildren#" index="LOCAL.parts">
										<cfset LOCAL.key = JavaCast('null', '')>
										<cfset LOCAL.fileName = JavaCast('null', '')>
										<cfset LOCAL.container = JavaCast('null', '')>
										<cfset LOCAL.size = JavaCast('null', '')>
										<cfset LOCAL.duration = JavaCast('null', '')>
												
										<cfif StructKeyExists(LOCAL.parts, 'XmlAttributes')>
											<cfdump var="#LOCAL.parts.XmlAttributes#">
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
												<cfset LOCAL.size = (IsNumeric(LOCAL.parts.XmlAttributes.size) ? LOCAL.parts.XmlAttributes.size : JavaCast('null', ''))>
											</cfif>
											<cfif StructKeyExists(LOCAL.parts.XmlAttributes, 'duration')>
												<cfset LOCAL.duration = (IsNumeric(LOCAL.parts.XmlAttributes.duration) ? LOCAL.parts.XmlAttributes.duration : JavaCast('null', ''))>
											</cfif>
										</cfif>
										
										<cfset QueryAddRow(LOCAL.qTheirMovies)>
										
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'libraryTitle', ARGUMENTS.libraryTitle)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'art', LOCAL.art)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'thumb', LOCAL.thumb)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'summary', LOCAL.summary)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'studio', LOCAL.studio)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'originallyAvailableAt', LOCAL.originallyAvailableAt)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'contentRating', LOCAL.contentRating)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'title', LOCAL.title)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'year', ((NOT IsNumeric(LOCAL.year)) ? 0 : LOCAL.year))>
										
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'videoResolution', LOCAL.videoResolution)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'aspectRatio', LOCAL.aspectRatio)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'audioChannels', LOCAL.audioChannels)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'audioCodec', LOCAL.audioCodec)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'bitrate', LOCAL.bitrate)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'height', LOCAL.height)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'width', LOCAL.width)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'videoFrameRate', LOCAL.videoFrameRate)>
										
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'key', LOCAL.key)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'fileName', LOCAL.fileName)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'container', LOCAL.container)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'size', LOCAL.size)>
										<cfset QuerySetCell(LOCAL.qTheirMovies, 'duration', LOCAL.duration)>
										
										<cfdump var="#LOCAL.qTheirMovies#" abort>
									</cfloop>
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>			
				
			</cfif>	
		</cfif>
	
		<cfreturn LOCAL.qTheirMovies>
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
	
	
	<cffunction name="DownloadPhotos" access="public" returnType="void" output="true">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		<cfargument name="qTheirPhotos" type="query">					
		<cfargument name="photoDropPath" type="string">
		
		<cfset LOCAL.qTheirPhotos = Duplicate(ARGUMENTS.qTheirPhotos)>

		<cfloop query="LOCAL.qTheirPhotos">
			<cfset LOCAL.savePath = ARGUMENTS.photoDropPath  & validFolderName(LOCAL.qTheirPhotos.collectionTitle)>
			
			<cfif NOT DirectoryExists(LOCAL.savePath)>
				<cfdirectory action="create" directory="#LOCAL.savePath#">
			</cfif>
			
			<cfset LOCAL.newFileName = validFileName(LOCAL.qTheirPhotos.photoTitle & '.' & LOCAL.qTheirPhotos.photoContainer)>
<!---
<cfoutput>#ARGUMENTS.pmsURL##LOCAL.qTheirPhotos.photoKey#?#ARGUMENTS.pmsTokenStr#</cfoutput><cfabort>
--->
			<cfhttp method="GET"
				url="#ARGUMENTS.pmsURL##LOCAL.qTheirPhotos.photoKey#?#ARGUMENTS.pmsTokenStr#" 
				path="#LOCAL.savePath#" 
				file="#LOCAL.newFileName#" />
		</cfloop>
		
		<cfreturn>
	</cffunction>
	
	<cffunction name="DownloadMovies" access="public" returnType="void" output="true">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		<cfargument name="qTheirMovies" type="query">					
		<cfargument name="movieDropPath" type="string">
		
		<cfset LOCAL.manualDL = False>
		
		<cfset LOCAL.qTheirMovies = Duplicate(ARGUMENTS.qTheirMovies)>

		<cfloop query="LOCAL.qTheirMovies">
			<cfset LOCAL.newFileName = LOCAL.qTheirMovies.title& ' (' & LOCAL.qTheirMovies.year & ').' & LOCAL.qTheirMovies.container>
			
			<cfif LOCAL.manualDL>
				<cfoutput>
				
				<input type="button" name="copyFileName" value="Copy" onClick="copyFileName('#title# (#year#).#container#');"> 
				<a href="#ARGUMENTS.pmsURL##LOCAL.qTheirMovies.key#?#ARGUMENTS.pmsTokenStr#">#title# (#year#) </a>[#videoResolution#] - #NumberFormat(size / 1024 / 1024)# MB | 
				&nbsp;[<a href="https://www.imdb.com/find?ref_=nv_sr_fn&q=#URLEncodedFormat(title & '(' & year & ')')#&s=all" target="_blank">IMDB</a>]<br></cfoutput>
			<cfelse>
				<cfhttp method="GET"
					url="#ARGUMENTS.pmsURL##LOCAL.qTheirMovies.key#?#ARGUMENTS.pmsTokenStr#" 
					path="#ARGUMENTS.movieDropPath#" 
					file="#LOCAL.newFileName#" />
					
				<cfset Sleep(2000)>
			</cfif>
		</cfloop>
		
		<cfreturn>
	</cffunction>
	
	<cffunction name="DownloadEpisodes" access="public" returnType="void" output="true">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		<cfargument name="qTheirEpisodes" type="query">					
		<cfargument name="tvDropPath" type="string">
		
		<cfset LOCAL.manualDL = False>
		<cfset prevShowTitle = ''>
		
		<cfset LOCAL.qTheirEpisodes = Duplicate(ARGUMENTS.qTheirEpisodes)>
		
		<cfloop query="LOCAL.qTheirEpisodes">
			<cfset LOCAL.seasonNum = ReplaceNoCase(LOCAL.qTheirEpisodes.seasonTitle, 'Season ', '')>
			<cfset LOCAL.seasonNum = 's' & ((IsNumeric(LOCAL.seasonNum) AND (LOCAL.seasonNum LT 10)) ? '0' & LOCAL.seasonNum : LOCAL.seasonNum)>
			
			<cfset LOCAL.episodeNum = 'e' & ((IsNumeric(LOCAL.qTheirEpisodes.episodeNum) AND (LOCAL.qTheirEpisodes.episodeNum LT 10)) ? '0' & LOCAL.qTheirEpisodes.episodeNum : LOCAL.qTheirEpisodes.episodeNum)>
			
			<cfset LOCAL.newFileName = LOCAL.qTheirEpisodes.showTitle & ' - '
				& LOCAL.seasonNum & LOCAL.episodeNum & ' - ' 
				& LOCAL.qTheirEpisodes.episodeTitle & '.' & LOCAL.qTheirEpisodes.episodeContainer>
				
			<!--- TODO: Replace Special Characters Not ALlowed In File Name --->
			<cfset LOCAL.newFileName = ReplaceNoCase(ReplaceNoCase(LOCAL.newFileName, ' :', ' -', 'ALL'), ':', ' -', 'ALL')>			
			
			<cfif LOCAL.manualDL>
				<cfif LOCAL.qTheirEpisodes.showTitle NEQ prevShowTitle>
					<cfoutput><h3>#LOCAL.qTheirEpisodes.showTitle#</h3></cfoutput>
					<cfset prevShowTitle = LOCAL.qTheirEpisodes.showTitle>
				</cfif>
				<cfoutput>
				
				<input type="button" name="copyFileName" value="Copy" onClick="copyFileName('#LOCAL.newFileName#');"> 
				<a href="#ARGUMENTS.pmsURL##LOCAL.qTheirEpisodes.episodeKey#?#ARGUMENTS.pmsTokenStr#">#LOCAL.newFileName# </a>[#episodeVideoResolution#] - #NumberFormat(episodeSize / 1024 / 1024)# MB | 
				&nbsp;[<a href="https://www.imdb.com/find?ref_=nv_sr_fn&q=#URLEncodedFormat(LOCAL.qTheirEpisodes.showTitle)#&s=all" target="_blank">IMDB</a>]<br></cfoutput>
			<cfelse>				
				<cfset LOCAL.savePath = ARGUMENTS.tvDropPath & LOCAL.qTheirEpisodes.showTitle>
				
				<cfif NOT DirectoryExists(LOCAL.savePath)>
					<cfdirectory action="create" directory="#LOCAL.savePath#">
				</cfif>
				
				<!--- Get Any Previously Downloaded Episodes --->
				<cfdirectory name="LOCAL.qDropEpisodes" directory="#savePath#">

				<!--- Check If Current EPisode Already Downloaded, If So Ensure Sizes Are The Same --->
				<cfquery name="LOCAL.qDropEpisodesMatch" dbtype="query">
					SELECT *
					FROM [LOCAL].qDropEpisodes
					WHERE UPPER(name) = <cfqueryparam value="#UCase(LOCAL.newFileName)#" CFSQLType="CF_SQL_VARCHAR">
						AND [size] = <cfqueryparam value="#episodeSize#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<!--- Not A Qualifying Duplicate Found In Drop Folder --->
				<cfif (LOCAL.qDropEpisodesMatch.recordcount EQ 0)>
					<!--- Download Episode To Drop Folder --->
					<cfhttp method="GET"
						url="#ARGUMENTS.pmsURL##LOCAL.qTheirEpisodes.episodeKey#?#ARGUMENTS.pmsTokenStr#" 
						path="#LOCAL.savePath#" 
						file="#LOCAL.newFileName#" />
						
					<!--- Plex Server Seems To Only Feed 1 Stream At A Time To Session, Make Delay To Ensure Stream Complete --->
					<cfset Sleep(2000)>
				</cfif>

				
				
			</cfif>
		</cfloop>
		
		<cfreturn>
	</cffunction>
	
	<cffunction name="DownloadTracks" access="public" returnType="void" output="true">
		<cfargument name="pmsURL" type="string">
		<cfargument name="pmsTokenStr" type="string">
		<cfargument name="qTheirTracks" type="query">					
		<cfargument name="musicDropPath" type="string">
		
		<cfset prevShowTitle = ''>
		
		<cfset LOCAL.qTheirTracks = Duplicate(ARGUMENTS.qTheirTracks)>
		
		<cfloop query="LOCAL.qTheirTracks">
			<cfset LOCAL.artistTitle = LOCAL.qTheirTracks.artistTitle> 
			<cfset LOCAL.albumTitle = LOCAL.qTheirTracks.albumTitle>			
			<cfset LOCAL.trackNum = ((IsNumeric(LOCAL.qTheirTracks.trackNum) AND (LOCAL.qTheirTracks.trackNum LT 10)) ? '0' & LOCAL.qTheirTracks.trackNum : LOCAL.qTheirTracks.trackNum)>
			<cfset LOCAL.trackTitle = LOCAL.qTheirTracks.trackTitle>

			<cfset LOCAL.newFileName = LOCAL.artistTitle & ' - '
				& LOCAL.albumTitle & ' - ' 
				& LOCAL.trackNum & ' - ' 
				& LOCAL.trackTitle & '.' & LOCAL.qTheirTracks.trackContainer>
				
			<cfset LOCAL.newFileName = validFileName(LOCAL.newFileName)>	
							
			<cfset LOCAL.savePath = ARGUMENTS.musicDropPath  & validFolderName(LOCAL.artistTitle)>
			
			<cfif NOT DirectoryExists(LOCAL.savePath)>
				<cfdirectory action="create" directory="#LOCAL.savePath#">
			</cfif>
			
			<cfset LOCAL.savePath &= '\' & validFolderName(LOCAL.albumTitle)>
		
			<cfif NOT DirectoryExists(LOCAL.savePath)>
				<cfdirectory action="create" directory="#LOCAL.savePath#">
				
				<!--- Download Episode To Drop Folder --->
				<cfhttp method="GET"
					url="#ARGUMENTS.pmsURL##LOCAL.qTheirTracks.albumArt#?#ARGUMENTS.pmsTokenStr#" 
					path="#LOCAL.savePath#" 
					file="folder.jpg" />
			</cfif>
			
			<!--- Get Any Previously Downloaded Episodes --->
			<cfdirectory name="LOCAL.qDropTracks" directory="#LOCAL.savePath#">
			
			

			<!--- Check If Current Track Already Downloaded, If So Ensure Sizes Are The Same --->
			<cfquery name="LOCAL.qDropTracksMatch" dbtype="query">
				SELECT *
				FROM [LOCAL].qDropTracks
				WHERE UPPER(name) = <cfqueryparam value="#UCase(validFileName(LOCAL.newFileName))#" CFSQLType="CF_SQL_VARCHAR">
					<!--- AND [size] = <cfqueryparam value="#LOCAL.qTheirTracks.trackSize#" cfsqltype="CF_SQL_INTEGER"> --->
			</cfquery>
<!---
<cfdump var="#LOCAL.qDropTracksMatch#">
<cfdump var="#LOCAL.qDropTracks#" abort>
--->		
			<!--- Not A Qualifying Duplicate Found In Drop Folder --->
			<cfif (LOCAL.qDropTracksMatch.recordcount EQ 0)>
				<!--- Download Episode To Drop Folder --->
				<cfhttp method="GET"
					url="#ARGUMENTS.pmsURL##LOCAL.qTheirTracks.trackKey#?#ARGUMENTS.pmsTokenStr#" 
					path="#LOCAL.savePath#" 
					file="#LOCAL.newFileName#" />
					
				<!--- Plex Server Seems To Only Feed 1 Stream At A Time To Session, Make Delay To Ensure Stream Complete --->
				<cfset Sleep(500)>
			</cfif>

		</cfloop>
		
		<cfreturn>
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
        <!---<cfset ARGUMENTS.fileName = Replace(ARGUMENTS.fileName, ".", "_", "ALL")>--->
        
        <cfif ListFindNoCase("PRN,AUX,NUL,LPT1,COM1,CON", ARGUMENTS.fileName)>
              <cfset ARGUMENTS.fileName ="Folder">
        </cfif>
        
        <cfset ARGUMENTS.fileName &= '.' & LOCAL.ext>
        
        <cfreturn ARGUMENTS.fileName>
	</cffunction>
	
	
</cfcomponent>
