
# return contract; always raises error; don't care re return.
AlwaysRaises = Contracts::Any

ControllerInstance = Contracts::RespondTo[:view_cache_dependency]

Hashlike = Contracts::RespondTo[:to_hash]

ViewHelper = Contracts::RespondTo[:content_tag]
