
#Translate and install .desktop file
i18n.merge_file(
    input: 'app.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Translate and install our .appdata file
i18n.merge_file(
    input: 'app.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Install logo
install_data(
    'logo.png',
    rename: meson.project_name() + '.png',
    install_dir: join_paths(get_option('datadir'), 'icons')
)

# Install GSettings schema
install_data(
    'app.gschema.xml',
    rename: meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)