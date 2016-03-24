-- 

hook.Add( "Message", "WikI!", function( _, _, msg )
    local searchTerm = msg:match( "^!wiki (.*)" )
    
    if not searchTerm then
      return
    end
    
    searchTerm = searchTerm:gsub( " ", "%%20" )
    
    http.Fetch("https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&explaintext=true&exchars=256&redirects&titles=" .. searchTerm,
      function(c, b)
        pcall( function()
          local pageObject = select( 2, next( json.decode( b ) . query . pages ) )
          local ex = pageObject.extract
          
          if not ex or #ex < 5 then
            return
          end
          
          print( ex )
          print( string.format( "from http://en.wikipedia.org/?curid=%s", pageObject.pageid ) )
        end )
      end )
end )
