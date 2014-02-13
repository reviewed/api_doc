ApiDoc::Engine.routes.draw do
  get "*path", to: "documents#show", as: :api_doc_page
  root to: "documents#index", as: :api_doc_home
end