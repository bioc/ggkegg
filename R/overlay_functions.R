#' overlay_raw_map
#' 
#' Overlay the raw KEGG pathway image on ggraph
#' 
#' @param pid pathway ID
#' @param directory directory to store images if not use cache
#' @param transparent_colors make these colors transparent to overlay
#' Typical choice of colors would be:
#' "#CCCCCC", "#FFFFFF","#BFBFFF","#BFFFBF", "#7F7F7F", "#808080",
#' "#ADADAD","#838383","#B3B3B3"
#' @param clip clip the both end of x- and y-axis by one dot
#' @param adjust adjust the x-axis location by 0.5 in data coordinates
#' @param adjust_manual_x adjust the position manually for x-axis
#' Override `adjust`
#' @param adjust_manual_y adjust the position manually for y-axis
#' Override `adjust`
#' @param use_cache whether to use BiocFileCache()
#' @import magick
#' @return ggplot2 object
#' @export
#' @examples
#' ## Need `pathway_id` column in graph 
#' ## if the function is to automatically infer
#' graph <- create_test_pathway() |> mutate(pathway_id="hsa04110")
#' ggraph(graph) + overlay_raw_map()
#'
overlay_raw_map <- function(pid=NULL, directory=NULL,
                            transparent_colors=c("#FFFFFF",
                                "#BFBFFF","#BFFFBF","#7F7F7F",
                                "#808080"),
                            adjust=TRUE,
                            adjust_manual_x=NULL,
                            adjust_manual_y=NULL,
                            clip=FALSE,
                            use_cache=TRUE) {
    structure(list(pid=pid,
                    transparent_colors=transparent_colors,
                    adjust=adjust,
                    clip=clip,
                    adjust_manual_x=adjust_manual_x,
                    adjust_manual_y=adjust_manual_y,
                    directory=directory,
                    use_cache=use_cache),
            class="overlay_raw_map")
}

#' ggplot_add.overlay_raw_map
#' @param object An object to add to the plot
#' @param plot The ggplot object to add object to
#' @param object_name The name of the object to add
#' @export ggplot_add.overlay_raw_map
#' @return ggplot2 object
#' @importFrom grDevices as.raster
#' @export
#' @examples
#' ## Need `pathway_id` column in graph 
#' ## if the function is to automatically infer
#' graph <- create_test_pathway() |> mutate(pathway_id="hsa04110")
#' ggraph(graph) + overlay_raw_map()
#'
ggplot_add.overlay_raw_map <- function(object, plot, object_name) {
    if (is.null(object$pid)) {
        infer <- plot$data$pathway_id |> unique()
        object$pid <- infer[!is.na(infer)]
    }
    if (!grepl("[[:digit:]]", object$pid)) {
        warning("Looks like not KEGG ID for pathway")
        return(1)
    }
    ## Return the image URL, download and cache
    url <- paste0(as.character(pathway(object$pid,
                                    use_cache=object$use_cache,
                                    directory=object$directory,
                                    return_image=TRUE)))
    if (object$use_cache) {
        bfc <- BiocFileCache()
        path <- bfcrpath(bfc, url)    
    } else {
        path <- paste0(object$pid, ".png")
        if (!is.null(object$directory)) {
            path <- paste0(object$directory,"/",path)
        }
        download.file(url=url, destfile=path, mode='wb')
    }
  
    ## Load, transparent and rasterize
    magick_image <- image_read(path)
    img_info <- image_info(magick_image)
    w <- img_info$width
    h <- img_info$height
  
    for (col in object$transparent_colors) {
        magick_image <- magick_image |> 
            image_transparent(col)
    }
  
    ras <- as.raster(magick_image)


    xmin <- 0
    xmax <- w
    ymin <- -1*h
    ymax <- 0

    if (object$clip) {
        ras <- ras[seq_len(nrow(ras)-1),
                    seq_len(ncol(ras)-1)]
    }
    if (!is.null(object$adjust_manual_x)) {
        object$adjust <- FALSE
        xmin <- xmin + object$adjust_manual_x
        xmax <- xmax + object$adjust_manual_x
    }
    if (!is.null(object$adjust_manual_y)) {
        object$adjust <- FALSE
        ymin <- ymin + object$adjust_manual_y
        ymax <- ymax + object$adjust_manual_y
    }
    if (object$adjust) {
        xmin <- xmin - 0.5
        xmax <- xmax - 0.5
        # ymin <- ymin - 0.5
        # ymax <- ymax - 0.5
    }
    plot + 
        annotation_raster(ras, xmin=xmin, ymin=ymin,
            xmax=xmax, ymax=ymax, interpolate=TRUE)+
        coord_fixed(xlim=c(xmin,xmax), ylim=c(ymin,ymax))
}
