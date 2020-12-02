defmodule LangueTest.Formatter.Resx20.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      <?xml version="1.0" encoding="utf-8"?>
      <root>
        <xsd:schema id="root" xmlns="" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
          <xsd:import namespace="http://www.w3.org/XML/1998/namespace" />
          <xsd:element name="root" msdata:IsDataSet="true">
            <xsd:complexType>
              <xsd:choice maxOccurs="unbounded">
                <xsd:element name="metadata">
                  <xsd:complexType>
                    <xsd:sequence>
                      <xsd:element name="value" type="xsd:string" minOccurs="0" />
                    </xsd:sequence>
                    <xsd:attribute name="name" use="required" type="xsd:string" />
                    <xsd:attribute name="type" type="xsd:string" />
                    <xsd:attribute name="mimetype" type="xsd:string" />
                    <xsd:attribute ref="xml:space" />
                  </xsd:complexType>
                </xsd:element>
                <xsd:element name="assembly">
                  <xsd:complexType>
                    <xsd:attribute name="alias" type="xsd:string" />
                    <xsd:attribute name="name" type="xsd:string" />
                  </xsd:complexType>
                </xsd:element>
                <xsd:element name="data">
                  <xsd:complexType>
                    <xsd:sequence>
                      <xsd:element name="value" type="xsd:string" minOccurs="0" msdata:Ordinal="1" />
                      <xsd:element name="comment" type="xsd:string" minOccurs="0" msdata:Ordinal="2" />
                    </xsd:sequence>
                    <xsd:attribute name="name" type="xsd:string" use="required" msdata:Ordinal="1" />
                    <xsd:attribute name="type" type="xsd:string" msdata:Ordinal="3" />
                    <xsd:attribute name="mimetype" type="xsd:string" msdata:Ordinal="4" />
                    <xsd:attribute ref="xml:space" />
                  </xsd:complexType>
                </xsd:element>
                <xsd:element name="resheader">
                  <xsd:complexType>
                    <xsd:sequence>
                      <xsd:element name="value" type="xsd:string" minOccurs="0" msdata:Ordinal="1" />
                    </xsd:sequence>
                    <xsd:attribute name="name" type="xsd:string" use="required" />
                  </xsd:complexType>
                </xsd:element>
              </xsd:choice>
            </xsd:complexType>
          </xsd:element>
        </xsd:schema>
        <resheader name="resmimetype">
          <value>text/microsoft-resx</value>
        </resheader>
        <resheader name="version">
          <value>2.0</value>
        </resheader>
        <resheader name="reader">
          <value>System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
        </resheader>
        <resheader name="writer">
          <value>System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
        </resheader>
        <data name="text" xml:space="preserve">
          <value>Los siguientes recursos no se pudieron cargar. 
          Asegúrese de que estén en el formato correcto y no estén dañados.

      {0}</value>
        </data>
        <data name="key" xml:space="preserve">
          <value>value</value>
        </data>
      </root>
      """
    end

    def entries do
      [
        %Entry{
          key: "text",
          value_type: "string",
          value: "Los siguientes recursos no se pudieron cargar. \n    Asegúrese de que estén en el formato correcto y no estén dañados.\n\n{0}",
          index: 1
        },
        %Entry{key: "key", value_type: "string", value: "value", index: 2}
      ]
    end
  end
end
