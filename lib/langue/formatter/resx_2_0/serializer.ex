defmodule Langue.Formatter.Resx20.Serializer do
  @moduledoc false
  @behaviour Langue.Formatter.Serializer

  @xml_template """
  <?xml version="1.0" encoding="utf-8"?>
  """

  @xsd [
    {"xsd:schema",
     [
       {"id", "root"},
       {"xmlns", ""},
       {"xmlns:xsd", "http://www.w3.org/2001/XMLSchema"},
       {"xmlns:msdata", "urn:schemas-microsoft-com:xml-msdata"}
     ],
     [
       {"xsd:import", [{"namespace", "http://www.w3.org/XML/1998/namespace"}], []},
       {"xsd:element",
        [
          {"name", "root"},
          {"msdata:IsDataSet", "true"}
        ],
        [
          {"xsd:complexType", [],
           [
             {"xsd:choice", [{"maxOccurs", "unbounded"}],
              [
                {"xsd:element", [{"name", "metadata"}],
                 [
                   {"xsd:complexType", [],
                    [
                      {"xsd:sequence", [],
                       [
                         {"xsd:element",
                          [
                            {"name", "value"},
                            {"type", "xsd:string"},
                            {"minOccurs", "0"}
                          ], []}
                       ]},
                      {"xsd:attribute",
                       [
                         {"name", "name"},
                         {"use", "required"},
                         {"type", "xsd:string"}
                       ], []},
                      {"xsd:attribute", [{"name", "type"}, {"type", "xsd:string"}], []},
                      {"xsd:attribute", [{"name", "mimetype"}, {"type", "xsd:string"}], []},
                      {"xsd:attribute", [{"ref", "xml:space"}], []}
                    ]}
                 ]},
                {"xsd:element", [{"name", "assembly"}],
                 [
                   {"xsd:complexType", [],
                    [
                      {"xsd:attribute", [{"name", "alias"}, {"type", "xsd:string"}], []},
                      {"xsd:attribute", [{"name", "name"}, {"type", "xsd:string"}], []}
                    ]}
                 ]},
                {"xsd:element", [{"name", "data"}],
                 [
                   {"xsd:complexType", [],
                    [
                      {"xsd:sequence", [],
                       [
                         {"xsd:element",
                          [
                            {"name", "value"},
                            {"type", "xsd:string"},
                            {"minOccurs", "0"},
                            {"msdata:Ordinal", "1"}
                          ], []},
                         {"xsd:element",
                          [
                            {"name", "comment"},
                            {"type", "xsd:string"},
                            {"minOccurs", "0"},
                            {"msdata:Ordinal", "2"}
                          ], []}
                       ]},
                      {"xsd:attribute",
                       [
                         {"name", "name"},
                         {"type", "xsd:string"},
                         {"use", "required"},
                         {"msdata:Ordinal", "1"}
                       ], []},
                      {"xsd:attribute",
                       [
                         {"name", "type"},
                         {"type", "xsd:string"},
                         {"msdata:Ordinal", "3"}
                       ], []},
                      {"xsd:attribute",
                       [
                         {"name", "mimetype"},
                         {"type", "xsd:string"},
                         {"msdata:Ordinal", "4"}
                       ], []},
                      {"xsd:attribute", [{"ref", "xml:space"}], []}
                    ]}
                 ]},
                {"xsd:element", [{"name", "resheader"}],
                 [
                   {"xsd:complexType", [],
                    [
                      {"xsd:sequence", [],
                       [
                         {"xsd:element",
                          [
                            {"name", "value"},
                            {"type", "xsd:string"},
                            {"minOccurs", "0"},
                            {"msdata:Ordinal", "1"}
                          ], []}
                       ]},
                      {"xsd:attribute",
                       [
                         {"name", "name"},
                         {"type", "xsd:string"},
                         {"use", "required"}
                       ], []}
                    ]}
                 ]}
              ]}
           ]}
        ]}
     ]}
  ]

  @resheaders [
    {"resheader", [{"name", "resmimetype"}], [{"value", [], ["text/microsoft-resx"]}]},
    {"resheader", [{"name", "version"}], [{"value", [], ["2.0"]}]},
    {"resheader", [{"name", "reader"}],
     [
       {"value", [],
        [
          "System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
        ]}
     ]},
    {"resheader", [{"name", "writer"}],
     [
       {"value", [],
        [
          "System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
        ]}
     ]}
  ]

  def serialize(%{entries: entries}) do
    nodes =
      Enum.map(entries, fn entry ->
        {"data",
         [
           {"name", entry.key},
           {"xml:space", "preserve"}
         ], [{"value", [], [entry.value]}]}
      end)

    render = XmlBuilder.generate({"root", [], @xsd ++ @resheaders ++ nodes})
    render = @xml_template <> render
    render = String.replace(render, "\"/>", "\" />")
    render = String.replace(render, "<value>\n      ", "<value>")
    render = String.replace(render, "\n    </value>", "</value>")
    render = render <> "\n"

    %Langue.Formatter.SerializerResult{render: render}
  end
end
