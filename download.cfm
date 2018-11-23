<cfsetting requestTimeOut = "0" />

<!---
<cfajaxproxy cfc="download.cfc" jsclassname="download_CFAJAXProxy"> 
--->

<cfoutput>
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">

    <title>Plex File Download!</title>
    
    <script language="javascript">
    	function js_UpdateProgress(current_progress) {
			$("##DLProgress")
			.css("width", current_progress + "%")
			.attr("aria-valuenow", current_progress)
			.text(current_progress + "% Complete");

    		return;	
    	}
    </script>
  </head>
  
  <body>
  	
  	<button type="button" class="btn btn-primary" onCLick="js_UpdateProgress(75);">Set Status Bar</button>
 
	<div class="progress md-progress" style="width:500px;height:20px">
		<div id="DLProgress" class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" style="width:25%;height:20px" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">25%</div>
	</div>
	<!---
	<div class="progress md-progress">
	    <div class="progress-bar progress-bar-striped progress-bar-animated bg-info" role="progressbar" style="width: 50%" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100"></div>
	</div>
	--->
	
	</cfoutput>

<cfset oUtility = CreateObject("component", "component.utility")>


<!--- https://www.shodan.io/search?query=CherryPy%2F5.1.0%2Fhome&page=1 --->

<cfif NOT IsDefined('URL.ip')>
	<cfoutput>No IP Set</cfoutput><cfabort>
<cfelse>
	<cfif NOT IsDefined('URL.type')>
		<cfoutput>No media type set</cfoutput><cfabort>
	<cfelse>
		<cfif (URL.type EQ 'movie')>
			<!--- Movie Code --->
		<cfelseif (URL.type EQ 'show')>
			<cfquery name="qDownloadShows" datasource="Plex">
				SELECT *
				FROM Shows
				WHERE EXISTS(SELECT TOP 1 1
					FROM Servers
					WHERE ip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#URL.ip#" maxlength="255">)
					<cfif IsDefined('URL.showTitle')>
					AND showTitle = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#URL.showTitle#" maxlength="255">
					</cfif>
					<cfif IsDefined('URL.seasonTitle')>
					AND seasonTitle = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#URL.seasonTitle#" maxlength="255">
					</cfif>
					<cfif IsDefined('URL.episodeNum') AND IsNumeric(URL.episodeNum)>
					AND episodeNum = <cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#URL.episodeNum#">
					</cfif>
					<cfif IsDefined('URL.videoResolution') AND IsNumeric(URL.videoResolution)>
					AND videoResolution = <cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#URL.videoResolution#">
					</cfif>
				ORDER BY showTitle, seasonTitle, episodeNum, videoResolution
			</cfquery>
			
			<cfif (qDownloadShows.recordcount EQ 0)>
				<cfoutput>No Server Data Found For IP #URL.ip#</cfoutput><cfabort>
			<cfelseif (IsDefined('URL.download') AND (URL.download))>
				<cfset oShows = CreateObject("component", "component.shows")>
			
				<!--- Download Show(s) --->
				<cfset  oShows.DownloadEpisodes(
					qDownloadShows = qDownloadShows
				)>
			<cfelse>
				<cfdump var="#qDownloadShows#" label="Download Shows" abort>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfoutput>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
  </body>
</html></cfoutput>
