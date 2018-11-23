<cfsetting requestTimeOut = "0" />

<cfset oServers = CreateObject("component", "component.servers")>


<!---
<cfdirectory name="qMovies" directory="\\ReadyNas2\videos\movies\">
<cfdirectory name="qComedians" directory="\\READYNAS2\Videos\Comedians\">

<cfquery name="qMyMovies" dbtype="query">
	SELECT *
	FROM qMovies
	UNION
	SELECT *
	FROM qComedians
</cfquery>
--->

<cfset movieDropPath = "\\READYNAS2\videos\Drops\movieDrops\">
<cfset tvDropPath = "\\READYNAS2\videos\Drops\tvDrops\">
<cfset musicDropPath = "\\READYNAS2\Videos\Drops\musicDrops\">
<cfset photoDropPath = "\\READYNAS2\Videos\Drops\photoDrops\">

<!---
<cfdirectory name="qDropMovies" directory="#movieDropPath#">

<cfdirectory name="qAlbums" recurse="yes" type="dir" directory="\\READYNAS2\Music\">

<cfquery name="qMyAlbums" dbtype="query">
	SELECT *
	FROM qAlbums
</cfquery>
--->

<cfoutput>
<html>
	<head>
		<title>PMS Hack Tool</title>
		
	</head>

	<body></cfoutput>

<cfset LOCAL.qServer = oServers.GetServers(
	URL = URL
)>

<cflock name="#LOCAL.qServer.ip#" type="exclusive" timeout="5">
	<cfset LOCAL.startSync = GetTickCount()>
	
	<cfset LOCAL.libraries = oServers.GetLibraries(
		qServer = LOCAL.qServer
	)>
	
	<cfset LOCAL.xmlLibraries = XmlParse(LOCAL.libraries)>
		
	<cfif StructKeyExists(LOCAL.xmlLibraries, 'MediaContainer')>
		<cfif StructKeyExists(LOCAL.xmlLibraries.MediaContainer, 'XMLChildren')>
			<cfset aLibraries = LOCAL.xmlLibraries.MediaContainer.XMLChildren>
	
			<cfif IsArray(aLibraries)>
				<cfloop array="#aLibraries#" index="library">
					<cfif StructKeyExists(library, 'XmlAttributes')>
						<cfif StructKeyExists(library.XmlAttributes, 'key')>
							<!--- MOVIES --->
							<cfif (library.XmlAttributes.type EQ 'movie') AND ((NOT IsDefined('URL.type')) OR (URL.type EQ 'movie'))>
								<cfset oMovies = CreateObject("component", "component.movies")>
								
								<!---
								<cfoutput>
								<a href="'http://#LOCAL.qServer.ip#:#LOCAL.qServer.port#/library/sections/#library.XmlAttributes.key#/all?X-Plex-Token=#LOCAL.qServer.token#" target="_blank">"#library.XmlAttributes.title#" (#library.XmlAttributes.type#)</a><br></cfoutput>
								--->
								
								<cfif ((NOT IsDefined('URL.library')) OR (URL.library EQ library.XmlAttributes.title))>
									<cfset oMovies.DeleteMovieLibraryData(
										serverID = LOCAL.qServer.serverID,
										libraryTitle = library.XmlAttributes.title
									)>									
									
									<cfset LOCAL.qMovies = oMovies.GetMovieLibrary(
										qServer = LOCAL.qServer,
										libraryTitle = library.XmlAttributes.title,
										libraryKey = library.XmlAttributes.key
									)>
									
									<cfset oMovies.SaveMovieLibraryData(
										serverID = LOCAL.qServer.serverID,
										qMovieLibraryData = LOCAL.qMovies
									)>
								</cfif>	
							<!--- SHOWS --->							
							<cfelseif (library.XmlAttributes.type EQ 'show') AND ((NOT IsDefined('URL.type')) OR (URL.type EQ 'show'))>
								<cfset oShows = CreateObject("component", "component.shows")>
								
								<!---	
								<cfoutput>
								<br><br>http://#LOCAL.qServer.ip#:#LOCAL.qServer.port#/library/sections/#library.XmlAttributes.key#/all?X-Plex-Token=#LOCAL.qServer.token#<a href="#LOCAL.qServer.ip#:#LOCAL.qServer.port#/library/sections/#library.XmlAttributes.key#/all?X-Plex-Token=#LOCAL.qServer.token#" target="_blank">"#library.XmlAttributes.title#" (#library.XmlAttributes.type#)</a><br><br></cfoutput>
								--->
								
								<cfset qTheirShows = oShows.GetShows(
									libraryTitle = library.XmlAttributes.title,
									url = LOCAL.qServer.ip & ':' & LOCAL.qServer.port & '/library/sections/' & library.XmlAttributes.key & '/all?X-Plex-Token=' & LOCAL.qServer.token
								)>
								
								<cfif (qTheirShows.recordcount GT 0)>								
									<cfset qTheirSeasons = oShows.GetSeasons(
										qServer = LOCAL.qServer,
										libraryTitle = library.XmlAttributes.title,
										qTheirShows = qTheirShows
									)>
									
									<cfif (qTheirSeasons.recordcount GT 0)>
										<cfset oShows.DeleteShowLibraryData(
											serverID = LOCAL.qServer.serverID,
											libraryTitle = library.XmlAttributes.title
										)>	
																	
										<cfset LOCAL.qTheirEpisodes = oShows.GetEpisodes(
											qServer = LOCAL.qServer,
											libraryTitle = library.XmlAttributes.title,
											qTheirSeasons = qTheirSeasons
										)>
					
										<cfset oShows.SaveShowLibraryData(
											serverID = LOCAL.qServer.serverID,
											qShowLibraryData = LOCAL.qTheirEpisodes
										)>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					
				</cfloop>
			</cfif>
		</cfif>
	</cfif>
	
	<!---
		<cfcatch>
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>
	--->
	<cfset LOCAL.finishSync = GetTickCount()>
	<cfset LOCAL.syncDuration = (LOCAL.finishSync - LOCAL.startSync)>
	
	<!--- Log Sync Time --->
	<cfquery datasource="Plex">
		UPDATE Servers 
		SET syncDuration = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCAL.syncDuration#">,
			lastSync = getDate()
		WHERE serverID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCAL.qServer.serverID#">
	</cfquery>

</cflock>

<cfoutput>
</body>

</html></cfoutput>
