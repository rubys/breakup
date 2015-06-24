# utility routine to wrap XHR
def fetch(target, &callback)
  xhr = XMLHttpRequest.new()
  xhr.open('GET', target, true)

  def xhr.onreadystatechange()
    response = nil

    if xhr.readyState == 4
      if xhr.responseType == :json
        response = xhr.response
      elsif xhr.responseText
        response = JSON.parse(xhr.responseText)
      end

      callback(response) if response
    end
  end

  xhr.responseType = :json
  xhr.send()
end

class Main < React
  def initialize
    @index = []
    @links = {}
    @doctitle = {}
    @search = ''
  end

  def render
    #
    # Input form
    #
    _input.search! value: @search, placeholder: 'search string'
    _div do
      _input type: 'checkbox', checked: @checked
      _span 'include references'
    end

    #
    # Search results
    #
    if @search.length >= 3
      _h2 'Search Results'
      found = false
      terms = @search.split(/\s+/).map {|term| term.downcase()}

      _dl @index do |entry, index|
        title = entry[0] ? entry[0] : '""'
        next unless terms.all? {|term| title.downcase().include? term}
        found = true

        #
        # Matching definitions
        #
        _dt title, key: "dt-#{index}"
        _dd key: "dd-#{index}" do
          _ul entry[1] do |values|
            title = values[0]
            base = values[1]
            id = values[2]

            href = "#{base}/##{id}"
            _li do
              _a "#{title.text} - #{@doctitle[base]}", href: href
            end

            #
            # references
            #
            if @checked and @links[href] and not @links[href].empty?
              _ul @links[href] do |link|
                section = link[0]
                linkbase = link[1]
                # next if title.id == section.id and base == linkbase
                _li do
                  _a "#{@doctitle[linkbase]} #{section.text}",
                    href: "#{linkbase}/##{section.id}"
                end
              end
            end
          end
        end
      end

      # if nothing found, explain
      _em @index.empty? ? 'Loading...' : 'No matches' unless found
    end
  end

  # focus on input field, fetch data on initial load
  def componentDidMount()
    ~'#search'.focus()
    fetch('index.json') {|response| @index = response}
    fetch('links.json') {|response| @links = response}
    fetch('doctitle.json') {|response| @doctitle = response}
  end
end
