# hash:sha256:edc7e0ee4e508f979519c3717a395cdf47b630e79062b2e3b867345e786b439f
FROM registry.codeocean.com/codeocean/pytorch:2.4.0-cuda12.4.0-mambaforge24.5.0-0-python3.12.4-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN pip install -U --no-cache-dir \
    antipickle==0.2.0 \
    attrs==26.1.0 \
    beartype==0.18.0 \
    biopython==1.83 \
    einops==0.8.0 \
    gemmi==0.7.5 \
    jaxtyping==0.2.25 \
    matplotlib==3.10.9 \
    modelcif==1.0 \
    numba==0.59.0 \
    pandas==3.0.2 \
    pandera==0.24.0 \
    rdkit==2025.9.6 \
    tmtools==0.0.3 \
    tqdm==4.66.0 \
    typing-extensions==4.15.0

ADD "https://github.com/coder/code-server/releases/download/v4.100.3/code-server-4.100.3-linux-amd64.tar.gz" /.code-server/code-server.tar.gz

RUN cd /.code-server \
    && tar -xvf code-server.tar.gz \
    && rm code-server.tar.gz \
    && ln -s /.code-server/code-server-4.100.3-linux-amd64/bin/code-server /usr/bin/code-server \
    && mkdir -p /.vscode/extensions

RUN code-server --extensions-dir="/.vscode/extensions" --install-extension ms-python.python@2025.14.0 \
    && code-server --extensions-dir="/.vscode/extensions" --install-extension ms-toolsai.jupyter@2025.4.1 \
    && code-server --extensions-dir="/.vscode/extensions" --install-extension reditorsupport.r@2.8.6 \
    && code-server --extensions-dir="/.vscode/extensions" --install-extension saoudrizwan.claude-dev@3.35.1

COPY postInstall /
RUN /postInstall
