ALTER TABLE raw_data.producao
    ADD CONSTRAINT fk_tipo_producao FOREIGN KEY (producao_tipo_id)
        REFERENCES raw_data.producao_tipo(producao_tipo_id);

ALTER TABLE raw_data.equipe
    ADD CONSTRAINT fk_equipe_producao FOREIGN KEY (producao_id)
        REFERENCES raw_data.producao(producao_id);

ALTER TABLE raw_data.equipe
    ADD CONSTRAINT fk_equipe_pessoa FOREIGN KEY (pessoa_id)
        REFERENCES raw_data.pessoa(pessoa_id);
