railroady -C -o doc/rails_backend_controllers.dot
railroady -M -o doc/rails_backend_models.dot

dot -Tpng -Gsize=9,5\! -Gdpi=100 doc/rails_backend_controllers.dot > doc/rails_backend_controllers.png
dot -Tpng -Gsize=9,5\! -Gdpi=100 doc/rails_backend_models.dot > doc/rails_backend_models.png

ls doc/rails_backend_*
