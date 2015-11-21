-- 

hook.Add( "Message", "WikI!", function( _, _, msg )
    local searchTerm = msg:match( "^what is (.+)%??" )
    
    if not searchTerm then
      return
    end
    
    searchTerm = searchTerm:match "^a (.*)" or searchTerm
    searchTerm = searchTerm:match "^an (.*)" or searchTerm
    searchTerm = searchTerm:gsub( " ", "%%20" )
    
    http.Fetch("https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&explaintext=true&exchars=256&redirects&titles=" .. searchTerm,
      function(c, b)
        pcall( function()
          local ex = select( 2, next( json.decode( b ) . query . pages ) ) . extract
          
          if not ex or #ex < 5 then
            return
          end
          
          print( ex )
        end )
      end )
end )
