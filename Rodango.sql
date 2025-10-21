-- =============================================
-- BANCO DE DADOS RODANGO - REDE SOCIAL MULTIMÍDIA
-- =============================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS rodango;
USE rodango;

-- =============================================
-- TABELAS PRINCIPAIS
-- =============================================

-- Tabela de usuários
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    cover_url VARCHAR(500),
    location VARCHAR(100),
    website VARCHAR(200),
    birth_date DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    relationship_status ENUM('single', 'married', 'relationship', 'complicated', 'open'),
    work_place VARCHAR(100),
    education VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- Tabela de perfis de usuário
CREATE TABLE user_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    phone_number VARCHAR(20),
    language_preference ENUM('pt', 'en', 'es', 'fr') DEFAULT 'pt',
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',
    date_format ENUM('dd/mm/yyyy', 'mm/dd/yyyy', 'yyyy-mm-dd') DEFAULT 'dd/mm/yyyy',
    privacy_level ENUM('public', 'friends', 'private') DEFAULT 'friends',
    notification_settings JSON,
    theme_preference ENUM('light', 'dark', 'auto') DEFAULT 'light',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_profile (user_id)
);

-- Tabela de posts
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    media_type ENUM('text', 'image', 'video', 'audio', 'mixed') DEFAULT 'text',
    privacy ENUM('public', 'friends', 'only_me', 'custom') DEFAULT 'public',
    feeling_type ENUM('happy', 'sad', 'excited', 'loved', 'blessed', 'nostalgic', 'proud', 'other') NULL,
    location VARCHAR(100),
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_created (user_id, created_at),
    INDEX idx_privacy_created (privacy, created_at),
    FULLTEXT idx_content_fulltext (content)
);

-- Tabela de mídias dos posts
CREATE TABLE post_media (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    media_type ENUM('image', 'video', 'audio') NOT NULL,
    media_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    file_size INT,
    duration INT, -- para vídeos/áudio em segundos
    width INT,
    height INT,
    caption TEXT,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    INDEX idx_post_order (post_id, display_order)
);

-- Tabela de curtidas
CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (user_id, post_id),
    INDEX idx_post_likes (post_id, created_at)
);

-- Tabela de comentários
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id INT NULL, -- para respostas a comentários
    content TEXT NOT NULL,
    media_url VARCHAR(500),
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_post_comments (post_id, created_at),
    INDEX idx_user_comments (user_id, created_at)
);

-- Tabela de curtidas em comentários
CREATE TABLE comment_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    comment_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE,
    UNIQUE KEY unique_comment_like (user_id, comment_id)
);

-- =============================================
-- TABELAS DE RELACIONAMENTOS
-- =============================================

-- Tabela de amizades
CREATE TABLE friendships (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id_1 INT NOT NULL,
    user_id_2 INT NOT NULL,
    status ENUM('pending', 'accepted', 'rejected', 'blocked') DEFAULT 'pending',
    action_user_id INT NOT NULL, -- quem fez a última ação
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id_1) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id_2) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (action_user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_friendship (user_id_1, user_id_2),
    INDEX idx_user_friends (user_id_1, status),
    INDEX idx_user_friends_reverse (user_id_2, status)
);

-- Tabela de seguidores (follow system)
CREATE TABLE followers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_follow (follower_id, following_id),
    INDEX idx_follower (follower_id),
    INDEX idx_following (following_id)
);

-- =============================================
-- TABELAS DE GRUPOS
-- =============================================

-- Tabela de grupos
CREATE TABLE groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    cover_url VARCHAR(500),
    avatar_url VARCHAR(500),
    privacy ENUM('public', 'private', 'secret') DEFAULT 'public',
    created_by INT NOT NULL,
    member_count INT DEFAULT 0,
    post_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_privacy_active (privacy, is_active),
    FULLTEXT idx_group_search (name, description)
);

-- Tabela de membros de grupos
CREATE TABLE group_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('member', 'admin', 'moderator') DEFAULT 'member',
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by INT NULL,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_group_member (group_id, user_id),
    INDEX idx_group_members (group_id, role),
    INDEX idx_user_groups (user_id, role)
);

-- Tabela de posts em grupos
CREATE TABLE group_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    post_id INT NOT NULL,
    pinned BOOLEAN DEFAULT FALSE,
    pinned_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_group_post (group_id, post_id),
    INDEX idx_group_posts (group_id, created_at)
);

-- =============================================
-- TABELAS DE MENSAGENS
-- =============================================

-- Tabela de conversas
CREATE TABLE conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('direct', 'group') DEFAULT 'direct',
    title VARCHAR(100), -- para grupos
    avatar_url VARCHAR(500), -- para grupos
    created_by INT NOT NULL,
    last_message_id INT NULL,
    last_message_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_last_message (last_message_at)
);

-- Tabela de participantes de conversas
CREATE TABLE conversation_participants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('member', 'admin') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP NULL,
    last_read_message_id INT NULL,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_participant (conversation_id, user_id),
    INDEX idx_user_conversations (user_id, last_read_message_id)
);

-- Tabela de mensagens
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT,
    media_type ENUM('text', 'image', 'video', 'audio', 'file') DEFAULT 'text',
    media_url VARCHAR(500),
    file_size INT,
    reply_to_message_id INT NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_message_id) REFERENCES messages(id) ON DELETE SET NULL,
    INDEX idx_conversation_messages (conversation_id, created_at),
    INDEX idx_sender_messages (sender_id, created_at)
);

-- Tabela de visualizações de mensagens
CREATE TABLE message_views (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id INT NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_message_view (message_id, user_id),
    INDEX idx_user_views (user_id, viewed_at)
);

-- =============================================
-- TABELAS DE NOTIFICAÇÕES
-- =============================================

-- Tabela de notificações
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('like', 'comment', 'friend_request', 'message', 'group_invite', 'event', 'mention', 'share') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    related_entity_type ENUM('post', 'comment', 'user', 'group', 'event', 'message') NULL,
    related_entity_id INT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_notifications (user_id, is_read, created_at),
    INDEX idx_unread_notifications (user_id, is_read)
);

-- =============================================
-- TABELAS DE EVENTOS
-- =============================================

-- Tabela de eventos
CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    cover_url VARCHAR(500),
    event_type ENUM('public', 'private', 'friends_only') DEFAULT 'public',
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    location VARCHAR(200),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    max_attendees INT,
    is_online BOOLEAN DEFAULT FALSE,
    online_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_event_dates (start_date, end_date),
    INDEX idx_user_events (user_id, start_date)
);

-- Tabela de participantes de eventos
CREATE TABLE event_attendees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    status ENUM('going', 'interested', 'not_going') DEFAULT 'interested',
    invited_by INT NULL,
    rsvp_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_event_attendee (event_id, user_id),
    INDEX idx_event_attendees (event_id, status)
);

-- =============================================
-- TABELAS DE MARKETPLACE
-- =============================================

-- Tabela de categorias do marketplace
CREATE TABLE marketplace_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES marketplace_categories(id) ON DELETE SET NULL,
    INDEX idx_parent_category (parent_category_id)
);

-- Tabela de itens do marketplace
CREATE TABLE marketplace_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    condition ENUM('new', 'like_new', 'good', 'fair', 'poor') DEFAULT 'good',
    location VARCHAR(200) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    status ENUM('active', 'sold', 'reserved', 'expired', 'deleted') DEFAULT 'active',
    view_count INT DEFAULT 0,
    save_count INT DEFAULT 0,
    is_negotiable BOOLEAN DEFAULT FALSE,
    is_delivery_available BOOLEAN DEFAULT FALSE,
    delivery_price DECIMAL(6, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES marketplace_categories(id) ON DELETE RESTRICT,
    INDEX idx_seller_items (seller_id, status),
    INDEX idx_category_items (category_id, status),
    INDEX idx_location_items (location(50), status),
    FULLTEXT idx_item_search (title, description)
);

-- Tabela de imagens dos itens
CREATE TABLE marketplace_item_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES marketplace_items(id) ON DELETE CASCADE,
    INDEX idx_item_images (item_id, display_order)
);

-- Tabela de itens salvos
CREATE TABLE marketplace_saved_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    item_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES marketplace_items(id) ON DELETE CASCADE,
    UNIQUE KEY unique_saved_item (user_id, item_id)
);

-- =============================================
-- TABELAS DE MÚSICA E VÍDEOS
-- =============================================

-- Tabela de músicas
CREATE TABLE music_tracks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    album VARCHAR(100),
    genre VARCHAR(50),
    duration INT NOT NULL, -- em segundos
    audio_url VARCHAR(500) NOT NULL,
    cover_url VARCHAR(500),
    play_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    share_count INT DEFAULT 0,
    privacy ENUM('public', 'private', 'friends') DEFAULT 'public',
    is_explicit BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_music (user_id, created_at),
    INDEX idx_genre_music (genre, created_at),
    FULLTEXT idx_music_search (title, artist, album)
);

-- Tabela de playlists
CREATE TABLE music_playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    cover_url VARCHAR(500),
    privacy ENUM('public', 'private', 'friends') DEFAULT 'public',
    track_count INT DEFAULT 0,
    play_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_playlists (user_id, created_at)
);

-- Tabela de músicas nas playlists
CREATE TABLE playlist_tracks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    added_by INT NOT NULL,
    track_order INT DEFAULT 0,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (playlist_id) REFERENCES music_playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES music_tracks(id) ON DELETE CASCADE,
    FOREIGN KEY (added_by) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_playlist_track (playlist_id, track_id),
    INDEX idx_playlist_order (playlist_id, track_order)
);

-- Tabela de vídeos
CREATE TABLE videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration INT NOT NULL, -- em segundos
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    share_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    privacy ENUM('public', 'private', 'friends', 'unlisted') DEFAULT 'public',
    category VARCHAR(50),
    tags JSON,
    is_live BOOLEAN DEFAULT FALSE,
    live_status ENUM('scheduled', 'live', 'ended') DEFAULT 'ended',
    scheduled_start DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_videos (user_id, created_at),
    INDEX idx_category_videos (category, created_at),
    FULLTEXT idx_video_search (title, description)
);

-- =============================================
-- TABELAS DE FOTOS E ALBUNS
-- =============================================

-- Tabela de álbuns de fotos
CREATE TABLE photo_albums (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    cover_photo_id INT NULL,
    privacy ENUM('public', 'private', 'friends') DEFAULT 'public',
    photo_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_albums (user_id, created_at)
);

-- Tabela de fotos
CREATE TABLE photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    album_id INT NULL,
    title VARCHAR(200),
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    width INT,
    height INT,
    file_size INT,
    location VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    taken_at DATETIME NULL,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    privacy ENUM('public', 'private', 'friends') DEFAULT 'public',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (album_id) REFERENCES photo_albums(id) ON DELETE SET NULL,
    INDEX idx_user_photos (user_id, created_at),
    INDEX idx_album_photos (album_id, created_at)
);

-- =============================================
-- TABELAS DE STORIES
-- =============================================

-- Tabela de stories
CREATE TABLE stories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    media_type ENUM('image', 'video') NOT NULL,
    media_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration INT DEFAULT 24, -- horas que o story ficará disponível
    caption TEXT,
    location VARCHAR(100),
    view_count INT DEFAULT 0,
    reply_count INT DEFAULT 0,
    is_archived BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_stories (user_id, created_at),
    INDEX idx_expiring_stories (expires_at)
);

-- Tabela de visualizações de stories
CREATE TABLE story_views (
    id INT AUTO_INCREMENT PRIMARY KEY,
    story_id INT NOT NULL,
    user_id INT NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_story_view (story_id, user_id),
    INDEX idx_user_story_views (user_id, viewed_at)
);

-- =============================================
-- TABELAS DE SEGURANÇA E AUDITORIA
-- =============================================

-- Tabela de sessões de usuário
CREATE TABLE user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    device_type ENUM('web', 'mobile', 'tablet') DEFAULT 'web',
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_user_sessions (user_id, expires_at)
);

-- Tabela de atividades do usuário
CREATE TABLE user_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    related_entity_type VARCHAR(50),
    related_entity_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_activity (user_id, created_at),
    INDEX idx_activity_type (activity_type, created_at)
);

-- Tabela de bloqueios de usuário
CREATE TABLE user_blocks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    blocker_id INT NOT NULL,
    blocked_id INT NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_block (blocker_id, blocked_id),
    INDEX idx_blocker_blocks (blocker_id),
    INDEX idx_blocked_blocks (blocked_id)
);

-- =============================================
-- PROCEDURES E TRIGGERS
-- =============================================

-- Trigger para atualizar contadores de posts
DELIMITER //
CREATE TRIGGER after_post_insert
    AFTER INSERT ON posts
    FOR EACH ROW
BEGIN
    -- Atualizar contador de posts do usuário (se necessário)
    UPDATE users 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.user_id;
END//
DELIMITER ;

-- Trigger para atualizar contadores de likes
DELIMITER //
CREATE TRIGGER after_like_insert
    AFTER INSERT ON likes
    FOR EACH ROW
BEGIN
    -- Atualizar contador de likes do post
    UPDATE posts 
    SET like_count = like_count + 1,
        updated_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.post_id;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_like_delete
    AFTER DELETE ON likes
    FOR EACH ROW
BEGIN
    -- Atualizar contador de likes do post
    UPDATE posts 
    SET like_count = like_count - 1,
        updated_at = CURRENT_TIMESTAMP 
    WHERE id = OLD.post_id;
END//
DELIMITER ;

-- Trigger para atualizar último login
DELIMITER //
CREATE TRIGGER before_user_update
    BEFORE UPDATE ON users
    FOR EACH ROW
BEGIN
    IF NEW.last_login IS NOT NULL AND (OLD.last_login IS NULL OR NEW.last_login > OLD.last_login) THEN
        SET NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
END//
DELIMITER ;

-- =============================================
-- INSERIR DADOS INICIAIS
-- =============================================

-- Inserir categorias do marketplace
INSERT INTO marketplace_categories (name, description, icon) VALUES
('Eletrônicos', 'Smartphones, tablets, computadores e acessórios', 'fas fa-mobile-alt'),
('Moda', 'Roupas, calçados e acessórios', 'fas fa-tshirt'),
('Casa e Jardim', 'Móveis, decoração e jardinagem', 'fas fa-home'),
('Esportes', 'Equipamentos esportivos e suplementos', 'fas fa-basketball-ball'),
('Veículos', 'Carros, motos e peças', 'fas fa-car'),
('Imóveis', 'Casas, apartamentos e terrenos', 'fas fa-building'),
('Serviços', 'Prestação de serviços diversos', 'fas fa-tools'),
('Livros', 'Livros, revistas e materiais educativos', 'fas fa-book'),
('Brinquedos', 'Brinquedos e jogos infantis', 'fas fa-gamepad'),
('Outros', 'Outras categorias', 'fas fa-ellipsis-h');

-- Inserir usuário administrador padrão
INSERT INTO users (username, email, password_hash, first_name, last_name, bio, avatar_url, is_verified) VALUES
('admin', 'admin@rodango.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', 'Rodango', 'Administrador do sistema', 'https://randomuser.me/api/portraits/men/1.jpg', TRUE);

-- Inserir configurações de perfil para o admin
INSERT INTO user_profiles (user_id, language_preference, privacy_level, notification_settings) VALUES
(1, 'pt', 'public', '{"email": true, "push": true, "sms": false}');

-- =============================================
-- VIEWS ÚTEIS
-- =============================================

-- View para posts com informações do usuário
CREATE VIEW post_details AS
SELECT 
    p.*,
    u.username,
    u.first_name,
    u.last_name,
    u.avatar_url as user_avatar,
    COUNT(DISTINCT l.id) as like_count,
    COUNT(DISTINCT c.id) as comment_count,
    EXISTS(SELECT 1 FROM likes WHERE post_id = p.id AND user_id = CURRENT_USER) as is_liked_by_current_user
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN likes l ON p.id = l.post_id
LEFT JOIN comments c ON p.id = c.post_id
WHERE p.privacy IN ('public', 'friends')
GROUP BY p.id;

-- View para amizades mútuas
CREATE VIEW mutual_friendships AS
SELECT 
    f1.user_id_1 as user_id,
    f1.user_id_2 as friend_id,
    u.username as friend_username,
    u.first_name as friend_first_name,
    u.last_name as friend_last_name,
    u.avatar_url as friend_avatar
FROM friendships f1
JOIN friendships f2 ON f1.user_id_1 = f2.user_id_2 AND f1.user_id_2 = f2.user_id_1
JOIN users u ON f1.user_id_2 = u.id
WHERE f1.status = 'accepted' AND f2.status = 'accepted';

-- View para estatísticas do usuário
CREATE VIEW user_statistics AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(DISTINCT p.id) as post_count,
    COUNT(DISTINCT f.id) as friend_count,
    COUNT(DISTINCT fl.id) as follower_count,
    COUNT(DISTINCT fg.id) as following_count,
    COUNT(DISTINCT g.id) as group_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id AND p.privacy IN ('public', 'friends')
LEFT JOIN friendships f ON (u.id = f.user_id_1 OR u.id = f.user_id_2) AND f.status = 'accepted'
LEFT JOIN followers fl ON u.id = fl.following_id
LEFT JOIN followers fg ON u.id = fg.follower_id
LEFT JOIN group_members g ON u.id = g.user_id AND g.status = 'approved'
GROUP BY u.id, u.username;

-- =============================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- =============================================

-- Índices para buscas
CREATE INDEX idx_posts_created_desc ON posts(created_at DESC);
CREATE INDEX idx_users_created_desc ON users(created_at DESC);
CREATE INDEX idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);

-- Índices para geolocalização
CREATE INDEX idx_photos_location ON photos(latitude, longitude);
CREATE INDEX idx_events_location ON events(latitude, longitude);
CREATE INDEX idx_marketplace_location ON marketplace_items(latitude, longitude);

-- Índices para contadores
CREATE INDEX idx_posts_like_count ON posts(like_count DESC);
CREATE INDEX idx_videos_view_count ON videos(view_count DESC);
CREATE INDEX idx_music_play_count ON music_tracks(play_count DESC);

-- =============================================
-- FIM DO BANCO DE DADOS
-- =============================================