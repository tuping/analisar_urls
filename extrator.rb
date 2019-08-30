#encoding: utf-8
#configurar as colunas interessantes

class Extrator
  #colunas interess/antes
  @@colunas = {
    cliente: /cliente/i,
    site: /site/i
  }

  attr_reader :row

  def initialize(row)
    @row = row
  end

  def colunas
    @@colunas
  end

  def celula_by_regexp(regexp)
    row[row.keys.select{|x| x[regexp]}.first]
  end

  def celula(coluna)
    celula_by_regexp(@@colunas[coluna])
  end

  def to_hash
    Hash[
      @@colunas.map do |key, value|
        [key, celula_by_regexp(value)]
      end
    ]
  end
end

