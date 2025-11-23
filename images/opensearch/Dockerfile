#syntax=docker/dockerfile:1.20
FROM opensearchproject/opensearch:2.19.4
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

RUN /usr/share/opensearch/bin/opensearch-plugin install --batch analysis-icu \
    && /usr/share/opensearch/bin/opensearch-plugin install --batch analysis-phonetic
