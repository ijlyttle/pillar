% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multi.R
\name{colonnade}
\alias{colonnade}
\alias{squeeze}
\title{Format multiple vectors in a tabular display}
\usage{
colonnade(x, has_row_id = TRUE, width = NULL, ...)

squeeze(x, width = NULL, ...)
}
\arguments{
\item{x}{A list of vectors to format}

\item{has_row_id}{Include a column indicating row IDs? Pass \code{"*"} to mark
the row ID column with a star.}

\item{width}{Default width of the entire output, optional}

\item{...}{Ignored}
}
\description{
The vectors are formatted to fit horizontally into a user-supplied number of
characters per row.

The \code{squeeze()} function is called by \code{\link[=format]{format()}}  and \code{\link[=print]{print()}} and usually
doesn't need to be called manually.
It returns an object suitable for printing and formatting at a fixed width
with additional information about omitted columns.
}
\details{
Pillars may be distributed over multiple tiers if
\code{width > getOption("width")}. In this case each tier is at most
\code{getOption("width")} characters wide. The very first step of formatting
is to determine how many tiers are shown at most, and the width of each
tier.

To avoid unnecessary computation for showing very wide colonnades, a first
pass tries to fit all capitals into the tiers.
For each pillar whose capital fits, it is then decided in which tier it is
shown, if at all, and how much horizontal space it may use (either its
minimum or its maximum width).
Remaining space is then distributed proportionally to pillars that do not
use their desired width.

For fitting pillars in one or more tiers, it is first attempted to fit all
of them in the first tier.
If this succeeds (or if no more tiers are available), this fit is
accepted.
Otherwise, an attempt is made to fit all remaining pillars in the remaining
tiers (with a recursive call).
If there still are pillars that don't fit, the minimum-width fit is accepted.

In case all remaining pillars fit all remaining tiers, a heuristic
selects the optimal number of pillars in the first tier.
The tier is grown starting with all pillars that are fitting with their
desired width (at least one pillar will be used), and
attempts are made to fit the remaining pillars in the remaining tiers
(with a recursive call for each attempt).
The first successful fit
(or otherwise the initial minimum-width fit) is accepted.

For computing the pillar widths in a single tier, two cases are distinguished:
\enumerate{
\item When taking the minimum width for each pillar (plus one inter-pillar
space), at least one pillar does not fit.
In this case, the minimum width is assigned to all pillars that do fit,
the non-fitting pillars are stripped.
\item All pillars fit with their minimum width. In this case, starting at
the leftmost pillar, the maximum width is allocated to the pillars
until all available space is used.
}

The remaining space is distributed from left to right.
Each column gains space proportional to the fraction of missing and
remaining space,
rounded down.
Any space remaining after rounding is distributed from left to right,
one space per column.
}
\examples{
colonnade(list(a = 1:3, b = letters[1:3]))

long_string <- list(paste(letters, collapse = " "))
colonnade(long_string, width = 20)
colonnade(long_string, has_row_id = FALSE, width = 20)

# The width can also be overridden when calling format() or print():
print(colonnade(long_string), width = 20)

# If width is larger than getOption("width"), multiple tiers are created:
colonnade(rep(long_string, 4), width = Inf)
squeeze(colonnade(long_string), width = 20)
}
