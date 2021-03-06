module Cms::Fortress::SprocketHelper
  include TinyMCE::Rails::Helper

  def tinymce_init
    path = File.join(Rails.root, 'config', 'tinymce.yml')
    if File.exist?(path)
      config = YAML.load_file(path)
    else
      config = {}
    end

    options = {
      menubar: "tools format view",
      toolbar1: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | table | fullscreen code | image fmedia link",
      toolbar2: "",
      plugins: ["code", "fullscreen", "media", "link", "table"],
      language: "en"
    }.stringify_keys.merge(config)

  <<-EOF
  tinymce.init({
      #{configuration_from_options(options)},
      selector: 'textarea[data-cms-rich-text]',
      link_list: CmsFortress.media.othersUrl(),

      setup: function(ed) {

        ed.addButton('image', {
          title: 'Insert Image',
          onclick: function() {
            return CmsFortress.media.showImageDialog(ed);
          }
        });

        return ed.addButton('fmedia', {
          tooltip: 'Insert Video',
          icon: 'media',
          stateSelector: ['img[data-mce-object=video]', 'img[data-mce-object=iframe]'],
          onclick: function() {
            return CmsFortress.media.showVideoDialog(ed);
          }
        });

      }

    });
  EOF
  end

  private

  def configuration_from_options(options)
    options.map do |k, v|
      v.is_a?(Array) ? "#{k}: #{v}" : "#{k}: #{boolean_value(v)}"
    end.join(',')
  end

  def boolean_value(v)
    [true, false].include?(v) ? "#{v}" : "'#{v}'"
  end
end
