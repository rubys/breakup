#
# Main "layout" for the application, houses a single view
#

_html _width: 120 do
  _link rel: 'stylesheet', href: 'stylesheets/app.css'

  _h1_ 'Web Platform Search'

  _p! do
    _ 'Data source: '
    _a 'break up specs', href: '.'
    _ '.'
  end

  _h2_ 'Disclaimers'

  _p! do
    _ 'Currently indexes '
    _code '<dfn>'
    _ ' elements only.'
  end

  _p! do
    _ 'Data source is known to have problems with references.  See '
    _a 'announcement', 
      href: 'https://lists.w3.org/Archives/Public/public-html/2015Jun/0009.html'
    _ '.'
  end

  _h2_ 'Search'

  _p 'Enter a minimum of three characters to start the search:'

  _div_.main!

  _script src: 'app.js'
  _.render '#main' do
    _Main
  end
end
