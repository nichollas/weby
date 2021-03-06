module ExtensionsHelper
  # Busca as extensões existentes no sistema de forma ordenada pelo i18n
  def available_extensions_sorted
    #['teachers', 'feedback']
    Weby::extensions.map{|name,extension| [t("extensions.#{extension.name}.name"), extension.name]}
  end
end
