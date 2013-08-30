#lang scribble/doc
@(require "common.rkt" scribble/bnf
          (for-label net/http-client
                     racket/list
                     openssl))

@title[#:tag "http-client"]{HTTP Client}

@defmodule[net/http-client]{The @racketmodname[net/http-client] library provides
utilities to use the HTTP protocol.}

@defproc[(http-conn? [x any/c])
         boolean?]{

Identifies an HTTP connection.
                   
}

@defproc[(http-conn-live? [x any/c])
         boolean?]{

Identifies an HTTP connection that is "live", i.e. one for which
@racket[http-conn-send!] is valid.

}

@defproc[(http-conn)
         http-conn?]{

Returns a fresh HTTP connection.

}

@defproc[(http-conn-open! [hc http-conn?] [host (or/c bytes? string?)]
                          [#:ssl? ssl? (or/c boolean? ssl-client-context? symbol?) #f]
                          [#:port port (between/c 1 65535) (if ssl? 443 80)])
         void?]{

Uses @racket[hc] to connect to @racket[host] on port @racket[port]
using SSL if @racket[ssl?] is not @racket[#f] (using @racket[ssl?] as
an argument to @racket[ssl-connect] to, for example, check
certificates.)

If @racket[hc] is live, the connection is closed.

}

@defproc[(http-conn-open [host (or/c bytes? string?)]
                         [#:ssl? ssl? (or/c boolean? ssl-client-context? symbol?) #f]
                         [#:port port (between/c 1 65535) (if ssl? 443 80)])
         http-conn?]{

Calls @racket[http-conn-open!] with a fresh connection, which is returned.

}

@defproc[(http-conn-close! [hc http-conn?])
         void?]{

Closes @racket[hc] if it is live.

}

@defproc[(http-conn-abandon! [hc http-conn?])
         void?]{

Closes the output side of @racket[hc], if it is live.

}

@defproc[(http-conn-send! [hc http-conn-live?] [uri (or/c bytes? string?)]
                          [#:version version (or/c bytes? string?) #"1.1"]
                          [#:method method (or/c bytes? string? symbol?) #"GET"]
                          [#:headers headers (listof (or/c bytes? string?)) empty]
                          [#:data data (or/c false/c bytes? string?) #f])
         void?]{

Sends an HTTP request to @racket[hc] to the URI @racket[uri] using
HTTP version @racket[version] the method @racket[method] and the
additional headers given in @racket[headers] and the additional data
@racket[data].

This function does not support requests that expect
@litchar{100 (Continue)} responses.

}

@defproc[(http-conn-recv! [hc http-conn-live?]
                          [#:close? close? boolean? #f])
         (values bytes? (listof bytes?) input-port?)]{

Parses an HTTP response from @racket[hc].

Returns the status line, a list of headers, and an port which contains
the contents of the response.

If @racket[close?] is @racket[#t], then the connection will be closed
following the response parsing. If @racket[close?] is @racket[#f],
then the connection is only closed if the server instructs the client
to do so.

}

@defproc[(http-conn-sendrecv! [hc http-conn-live?] [uri (or/c bytes? string?)]
                              [#:version version (or/c bytes? string?) #"1.1"]
                              [#:method method (or/c bytes? string? symbol?) #"GET"]
                              [#:headers headers (listof (or/c bytes? string?)) empty]
                              [#:data data (or/c false/c bytes? string?) #f]
                              [#:close? close? boolean? #f])
         (values bytes? (listof bytes?) input-port?)]{

Calls @racket[http-conn-send!] and @racket[http-conn-recv!] in sequence.

}

@defproc[(http-sendrecv [host (or/c bytes? string?)] [uri (or/c bytes? string?)]
                        [#:ssl? ssl? (or/c boolean? ssl-client-context? symbol?) #f]
                        [#:port port (between/c 1 65535) (if ssl? 443 80)]
                        [#:version version (or/c bytes? string?) #"1.1"]                          
                        [#:method method (or/c bytes? string? symbol?) #"GET"]
                        [#:headers headers (listof (or/c bytes? string?)) empty]
                        [#:data data (or/c false/c bytes? string?) #f])
         (values bytes? (listof bytes?) input-port?)]{

Calls @racket[http-conn-send!] and @racket[http-conn-recv!] in
sequence on a fresh HTTP connection produced by
@racket[http-conn-open].

The HTTP connection is not returned, so it is always closed after one
response, which is why there is no @racket[#:closed?] argument like
@racket[http-conn-recv!].

}

