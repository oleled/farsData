#' Read a CSV file into a tibble (tidyverse dataframe)
#'
#' This function reads a CSV file into R as a tibble.
#'
#' @param filename The aboslute or relative path to the filename to read into
#'    R (should be a CSV file) .
#' 
#' @return The CSV data in tibble (tidyverse version of data frames) format.
#' 
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#' 
#' @note If the file doesn't exist, a message will be displayed saying so.
#'
#' @examples
#' df <- fars_read("./data/data.csv")
#' df <- fars_read("./data/accident_2013.csv.bz2")
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}


#' Creates a descriptive filename based on the input year.
#'
#' @param year The year that you would like in the filename.
#' 
#' @return A character object that represents the filename for car fatality data.  
#'
#' @example
#' \dontrun{
#'   make_filename(2014)
#' }
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' \code{fars_read_years} : Reads the year and finds the csv file matching
#' the same year. If the csv file is not found, 'invalid year' error is displayed.
#' if the year is appropriate,  the csv file is read and mutate a new column with
#' the year and then select the columns MONTH and year
#'
#' @importFrom dplyr mutate select %>%
#'
#' @param years A vector of year to be searched
#' @return A dataset with of the relevant year, with the columns MONTH and year.
#' Otherwise, an error 'invalid year' is displayed.
#'
#' @example
#' \dontrun{
#'   fars_read_years(c(2013, 2014))
#' }
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>% 
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Creates a table summarizing the count of fatal car incidents in a given month
#' and year combination.
#'
#' @param years a vector of years for which the number of fatal car incidents
#'     should be displayed, grouped by Month.
#' 
#' @return a data frame.
#' 
#' @importFrom dplyr bind_rows 
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize 
#' @importFrom dplyr spread 
#' 
#' @note If one of the years specified doesn't have an associated file, and error
#'    will be thrown.
#' 
#' @example
#' \dontrun{
#'   fars_summarize_years(c(2013,2014))
#' }
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>% 
                dplyr::group_by(year, MONTH) %>% 
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Creates a geographical plot showing the accidents for a given year in a given
#'    state. Each accident is plotted as a single dot.
#'
#' @param state.num The state number which you would like displayed.
#' @inheritParams make_filename
#'
#' @return Displays a plot (no object returned).
#'
#' @importFrom maps map
#' @importFrom dplyr filter
#' @importFrom graphics points 
#'
#' @note If the state.num argument doesn't correspond to a state within the 
#'    specified data frame's STATE column, and error will be thrown.
#' @note If there are no accidents to plot for the specified state.num/year combination
#'   a message will display saying so. 
#' 
#' @example
#' \dontrun{
#'   fars_map_state(1,2014)
#' }
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
