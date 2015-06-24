var SPECS = "http://darobin.github.io/breakup/specs";

// utility routine to wrap XHR
function fetch(target, callback) {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", target, true);

  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4 && xhr.response) callback(xhr.response)
  };

  xhr.responseType = "json";
  xhr.send()
};

var Main = React.createClass({
  displayName: "Main",

  getInitialState: function() {
    return {index: [], links: {}, doctitle: {}, search: ""}
  },

  render: function() {
    var self = this;

    return React.createElement.apply(React, function() {
      var $_ = ["span", null];

      //
      // Input form
      //
      $_.push(React.createElement("input", {
        value: self.state.search,
        placeholder: "search string",

        onChange: function(event) {
          self.setState({search: event.target.value})
        }
      }));

      $_.push(React.createElement(
        "div",
        null,

        React.createElement("input", {
          type: "checkbox",
          checked: self.state.checked,

          onChange: function() {
            self.setState({checked: !self.state.checked})
          }
        }),

        React.createElement("span", null, "include references")
      ));

      //
      // Search results
      //
      var found, terms;

      if (self.state.search.length >= 3) {
        $_.push(React.createElement("h2", null, "Search Results"));
        found = false;

        terms = self.state.search.split(/\s+/).map(function(term) {
          return term.toLowerCase()
        });

        $_.push(React.createElement.apply(React, function() {
          var $_ = ["dl", null];

          self.state.index.forEach(function(entry, index) {
            var title = (entry[0] ? entry[0] : "\"\"");

            if (!terms.every(function(term) {
              return title.toLowerCase().indexOf(term) != -1
            })) return;

            found = true;

            //
            // Matching definitions
            //
            $_.push(React.createElement("dt", {key: "dt-" + index}, title));

            $_.push(React.createElement(
              "dd",
              {key: "dd-" + index},

              React.createElement.apply(React, function() {
                var $_ = ["ul", null];

                entry[1].forEach(function(values) {
                  title = values[0];
                  var base = values[1];
                  var id = values[2];
                  var href = base + "/#" + id;

                  $_.push(React.createElement("li", null, React.createElement(
                    "a",
                    {href: SPECS + "/" + href},
                    title.text + " - " + self.state.doctitle[base]
                  )));

                  //
                  // references
                  //
                  if (self.state.checked && self.state.links[href] && self.state.links[href].length != 0) {
                    $_.push(React.createElement.apply(React, function() {
                      var $_ = ["ul", null];

                      self.state.links[href].forEach(function(link) {
                        var section = link[0];
                        var linkbase = link[1];

                        // next if title.id == section.id and base == linkbase
                        $_.push(React.createElement("li", null, React.createElement(
                          "a",
                          {href: SPECS + "/" + linkbase + "/#" + section.id},
                          self.state.doctitle[linkbase] + " " + section.text
                        )))
                      });

                      return $_
                    }()))
                  }
                });

                return $_
              }())
            ))
          });

          return $_
        }()));

        // if nothing found, explain
        if (!found) {
          $_.push(React.createElement(
            "em",
            null,
            (self.state.index.length == 0 ? "Loading..." : "No matches")
          ))
        }
      };

      return $_
    }())
  },

  // fetch data on initial load
  componentDidMount: function() {
    var self = this;

    fetch("index.json", function(response) {
      self.setState({index: response})
    });

    fetch("links.json", function(response) {
      self.setState({links: response})
    });

    fetch("doctitle.json", function(response) {
      self.setState({doctitle: response})
    })
  }
})