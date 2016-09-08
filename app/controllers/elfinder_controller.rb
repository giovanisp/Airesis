class ElfinderController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: ['elfinder']

  before_filter :load_group

  def elfinder
    @can_manage = can? :manage_documents, @group
    @can_view = can? :view_documents, @group

    # create root directory if does not exists
    Dir.mkdir("#{Rails.root}/private/elfinder/#{@group.id}") unless File.exist?("#{Rails.root}/private/elfinder/#{@group.id}")

    h, r = ElFinder::Connector.new(
      root: File.join(Rails.root, 'private', 'elfinder', @group.id.to_s),
      url: "documents/view?url=/private/elfinder/#{@group.id}",
      perms: {

        # /^(Welcome|README)$/ => {read: true, write: false, rm: false},
        '.' => { read: @can_view, write: @can_manage, rm: false }, # '.' is the proper way to specify the home/root directory.
        /.*/ => { read: @can_view, write: @can_manage, rm: @can_manage }
        # /^test$/ => {read: true, write: true, rm: false},
        # 'logo.png' => {read: true},
        # /\.png$/ => {read: false} # This will cause 'logo.png' to be unreadable.
        # Permissions err on the safe side. Once false, always false.
      },
      extractors: {
        'application/zip' => ['unzip', '-qq', '-o'], # Each argument will be shellescaped (also true for archivers)
        'application/x-gzip' => ['tar', '-xzf']
      },
      archivers: {
        'application/zip' => ['.zip', 'zip', '-qr9'], # Note first argument is archive extension
        'application/x-gzip' => ['.tgz', 'tar', '-czf']
      },
      upload_max_size: "#{@group.max_storage_size - @group.actual_storage_size}K"

    ).run(params)

    headers.merge!(h)

    render (r.empty? ? { nothing: true } : { text: r.to_json }), layout: false
  end
end
