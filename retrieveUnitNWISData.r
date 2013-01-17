#' Data Import for Instantaneous USGS NWIS Data
#'
#' Imports data from NWIS web service. This function gets the data from here: \url{http://waterservices.usgs.gov/}
#' A list of parameter codes can be found here: \url{http://nwis.waterdata.usgs.gov/nwis/pmcodes/}
#' A list of statistic codes can be found here: \url{http://nwis.waterdata.usgs.gov/nwis/help/?read_file=stat&format=table}
#'
#' @param siteNumber string USGS site number.  This is usually an 8 digit number
#' @param ParameterCd string USGS parameter code.  This is usually an 5 digit number.
#' @param StartDate string starting date for data retrieval in the form YYYY-MM-DD.
#' @param EndDate string ending date for data retrieval in the form YYYY-MM-DD.
#' @param interactive logical Option for interactive mode.  If true, there is user interaction for error handling and data checks.
#' @keywords data import USGS web service
#' @return retval dataframe with agency, site, dateTime, time zone, value, and code columns
#' @export
#' @examples
#' siteNumber <- '05114000'
#' ParameterCd <- '00060'
#' StartDate <- '2012-05-01'
#' EndDate <- '2012-05-02'
#' # These examples require an internet connection to run
#' rawData <- retrieveUnitNWISData(siteNumber,ParameterCd,StartDate,EndDate,interactive=FALSE)
retrieveUnitNWISData <- function (siteNumber,ParameterCd,StartDate,EndDate,interactive=TRUE){  
  
  baseURL <- "http://waterservices.usgs.gov/nwis/iv?site="
  
  url <- paste(baseURL,siteNumber, "&ParameterCd=",ParameterCd, "&format=rdb,1.0", sep = "")
  
  if (nzchar(StartDate)) {
    url <- paste(url,"&startDT=",StartDate,sep="")
  } else url <- paste(url,"&startDT=","1851-01-01",sep="")
  
  if (nzchar(EndDate)) {
    url <- paste(url,"&endDT=",EndDate,sep="")
  }
  
  tmp <- read.delim(  
    url, 
    header = TRUE, 
    quote="\"", 
    dec=".", 
    sep='\t',
    colClasses=c('character'),
    fill = TRUE, 
    comment.char="#")

  retval <- lapply(tmp, function(x) {
    Typ <- x[1] # The type - the first row shows the type (such as 5s = a string with 5 letters, 20d = a date, etc)
    x <- x[-1] # the data - takes away the first 2 rows (1st = header, 2nd = type)
    if(regexpr('d$', Typ) > 0) { # Must be date
      ret.val <- as.POSIXct(strptime(x, "%Y-%m-%d %H:%M")) 
    }
    else if(regexpr('n$', Typ) > 0) # Should be numeric...sometimes might be 'ice' or some other comment
      ret.val <- as.numeric(x)
    else # Must be character
      ret.val <- x
    return(ret.val)})
  retval <- as.data.frame(retval, stringsAsFactors=FALSE)  
  
  return (retval)
}