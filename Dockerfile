FROM levischuck/janet-sdk as builder

COPY project.janet /little-analytics/
WORKDIR /little-analytics/
RUN jpm deps
COPY . /little-analytics/
RUN jpm build && jpm build

FROM alpine as app
COPY --from=builder /little-analytics/build/little-analytics /usr/local/bin/
COPY db static /opt/
WORKDIR /opt/
CMD ["little-analytics"]